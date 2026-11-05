# Tutorial: Begegnungen, Kampf und Fangen

Hohes Gras → wilder Kampf mit Timing → Monster mit einem Amulett bannen → zurück auf die Map.
Stand: 2026-11-05, Godot 4.7, 2D top-down.

```
Spieler läuft im Gras (EncounterZone)
  └─ Zufall pro Schritt → EncounterTable.roll() → wildes MonsterInstance
       └─ SceneSwitcher.start_battle([wild])   Map pausieren + verstecken, Kampfszene öffnen
            └─ BattleScene: Attacke / Bannen / Fliehen, jede Aktion mit ActionCommand-Timing
                 └─ battle_finished("win" | "lose" | "caught" | "fled")
                      └─ SceneSwitcher.end_battle()   Kampf weg, Map läuft weiter
```

## 0. Schnell ausprobieren

1. `Szene/Tutorials/encounter_test.tscn` öffnen, **F6** (aktuelle Szene starten).
2. Mit **WASD** ins grüne Feld laufen. Nach ein paar Schritten startet ein Kampf.
3. Im Kampf: Attacke wählen und **Leertaste/Enter** drücken, wenn sich der gelbe Ring schließt (Aufprall).
   Greift der Gegner an, drückst du im selben Moment zum Blocken. „Exzellent!!“ = komplett ausgewichen.
4. **Bannen**: Ring schließt sich nach 1 Sekunde. Je weniger KP der Gegner hat und je besser dein Timing, desto höher die Chance.

## 1. Autoloads

Schon eingetragen (Projekt → Projekteinstellungen → Globals):

| Name | Datei | Wofür |
|---|---|---|
| `GameState` | `Scripts/Core/game_state.gd` | `party` (max. 6) und `box` |
| `SceneSwitcher` | `Scripts/Core/scene_switcher.gd` | Kampf starten und beenden |

## 2. Begegnungstabelle anlegen

Eine Tabelle pro Gebiet, z. B. für Route 1.

1. FileSystem → Rechtsklick auf `Resources/Encounters/` → **Neu → Resource…** → `EncounterTable` → `route01_gras.tres`.
2. Im Inspector bei **Entries** auf **+** klicken, als Typ **New EncounterEntry** wählen.
3. Pro Eintrag: **Monster** (eine `.tres` aus `Resources/Monsters/` hineinziehen), **Min/Max Level**, **Weight**.
   Weight ist relativ: 30 + 10 heißt 75 % / 25 %.

Das Beispiel `Resources/Encounters/tutorial_gras.tres` hat ein eingebettetes „Testmon“. Für echte Gebiete nimm die Monster aus `Resources/Monsters/`.

Der Code (`Scripts/Overworld/encounter_table.gd`) zieht nach Gewicht:

```gdscript
func roll() -> MonsterInstance:
	var total := 0
	for entry in entries:
		total += entry.weight
	if total <= 0:
		return null

	var pick := randi_range(1, total)
	for entry in entries:
		pick -= entry.weight
		if pick <= 0:
			return MonsterInstance.create(entry.monster, randi_range(entry.min_level, entry.max_level))
	return null
```

## 3. Hohes Gras in eine Map setzen

1. In der Map-Szene: **Kind-Node hinzufügen → Area2D**, Name `Gras`.
2. Skript `Scripts/Overworld/encounter_zone.gd` draufziehen.
3. Unter `Gras` eine **CollisionShape2D** mit **RectangleShape2D** anlegen und über die Gras-Kacheln ziehen.
4. Im Inspector: **Encounter Table** = deine Tabelle, **Chance Per Step** = z. B. `0.1` (10 % pro Schritt).
5. Der Spieler (CharacterBody2D) muss in der Gruppe **player** sein: Spieler-Node → Node-Dock → Gruppen → `player`.

Ein „Schritt“ sind 16 Pixel (eine Kachel, `STEP_SIZE`). Das klappt mit freier Bewegung und mit Kachel-Bewegung.
Das Gras-Aussehen kommt aus dem TileMapLayer, die Area2D ist nur die unsichtbare Zone darüber.

```gdscript
func _physics_process(_delta: float) -> void:
	if _player == null or encounter_table == null:
		return

	_distance_walked += _player.global_position.distance_to(_last_position)
	_last_position = _player.global_position
	if _distance_walked < STEP_SIZE:
		return

	_distance_walked = 0.0
	if randf() < chance_per_step:
		var wild := encounter_table.roll()
		if wild:
			SceneSwitcher.start_battle([wild])
```

## 4. Von der Map in den Kampf und zurück

`SceneSwitcher.start_battle(gegner_team, ist_trainer)` geht von überall, z. B. auch von einem Trainer-NPC:

```gdscript
SceneSwitcher.start_battle([MonsterInstance.create(preload("res://Resources/Monsters/Fuego.tres"), 7)], true)
```

Was passiert (`Scripts/Core/scene_switcher.gd`):
- Die Map wird **nicht gelöscht**, nur pausiert (`PROCESS_MODE_DISABLED`) und versteckt. So bleibt der Spieler genau da stehen, wo er war.
- `Szene/Battle/battle_scene.tscn` wird an die Wurzel gehängt und bekommt `GameState.party` und die Gegner.
- Ist der Kampf vorbei, sendet die Kampfszene `battle_finished(result)`. Der SceneSwitcher löscht sie, macht die Map wieder an und sendet `battle_ended(result)`.

Auf das Ergebnis reagieren, z. B. in einem Trainer-NPC:

```gdscript
var result: String = await SceneSwitcher.battle_ended
if result == "win":
	GameState.set_flag("trainer_route01_besiegt")
```

Die Kampfszene ist ein **CanvasLayer** (Ebene 10). Dadurch stört die Kamera der Map nicht und du brauchst keine eigene Kamera.

## 5. Der Kampfablauf

`Scripts/Battle/battle_scene.gd`, eine Runde:

1. Menü: eine Taste pro Attacke, dazu **Bannen** und **Fliehen** (nur bei wilden Monstern).
2. Der Gegner wählt per `EnemyAI.choose_move()` (im Moment zufällig).
3. Wer zuerst? Höhere `Priority` der Attacke, sonst höhere Initiative (`speed`).
4. Jeder Angriff, `_attack()`:
   - Der Angreifer läuft per Tween zum Ziel und kommt **genau beim ersten `TimingHits`-Zeitpunkt** an.
   - `ActionCommand.start_for_move(move)` startet das Timing, der `TimingRing` zeigt es an.
   - Spieler greift an: `ATTACK_MULTIPLIERS[stufe]` (0,5 … 1,3).
   - Gegner greift an: Gegner würfelt seine Stufe (`enemy_precision`), du blockst mit `DEFENSE_MULTIPLIERS[stufe]` (1,0 … 0,0).
   - Schaden kommt aus `DamageCalculator.calculate_damage()`.
5. K.O.? Nächstes Monster aus dem Team. Keins mehr → `"lose"`. Gegner besiegt → `"win"`.

Das Timing einer Attacke stellst du im Inspector der Attacke ein (Gruppe **Timing**, siehe `docs/ANLEITUNG.md`, Kap. 3).
Hat ein Monster noch keine Attacken, benutzt der Kampf automatisch „Rempler“.

Das Herzstück, gekürzt:

```gdscript
action_command.start_for_move(move)
var tier: int = await action_command.finished

var multiplier: float
if by_player:
	multiplier = ActionCommand.ATTACK_MULTIPLIERS[tier]
else:
	var enemy_tier := EnemyAI.roll_timing_tier(enemy_precision)
	multiplier = ActionCommand.ATTACK_MULTIPLIERS[enemy_tier] * ActionCommand.DEFENSE_MULTIPLIERS[tier]

var result := DamageCalculator.calculate_damage(_battle_data(attacker), _battle_data(defender), move, multiplier)
```

Aussehen ändern: `battle_scene.tscn` öffnen und Nodes verschieben (`EnemySprite`, `PlayerSprite`, KP-Balken, `Info`, `Buttons`). Die Namen müssen bleiben, das Skript sucht sie per `$Name`.

## 6. Bannen mit Schmuck

Ein Schmuckstück = ein Monster (`design/spielmechaniken.md`, Kap. 1).

**Rohling anlegen:** `Resources/Items/Amulets/Rohling_Kupfer.tres` duplizieren. Wichtige Werte:
- **Category** = `CAPTURE`
- **Catch Bonus**: Multiplikator für die Fangchance (Kupfer 1.0, Silber z. B. 1.5, Gold 2.0)
- **Bonus Hp / Attack / …**: Werte, die das Monster bekommt, das darin wohnt. `MonsterInstance.get_stat()` rechnet sie schon mit ein.

Welcher Rohling im Kampf benutzt wird, steht in `battle_scene.tscn` → **Catch Amulet**. Später kommt er aus dem Inventar.

**Formel** (`Scripts/Battle/catch_system.gd`):

```
Chance = Fangrate/100 × Catch Bonus × HP-Faktor × Timing-Bonus
HP-Faktor:    volle KP 0,5  …  fast 0 KP 1,5
Timing-Bonus: schlecht 0,5 · okay 0,8 · gut 1,0 · sehr gut 1,2 · exzellent 1,5
```

Beispiel: Fangrate 60, Kupfer, halbe KP, „sehr gut“ → 0,6 × 1,0 × 1,0 × 1,2 = **72 %**.

Klappt es, bekommt das Monster eine **Kopie** des Rohlings (`monster.amulet`) und kommt ins Team, bei 6 Monstern in die Box. Klappt es nicht, greift der Gegner an.

## 7. Was als Nächstes kommt

Im Code steht an diesen Stellen ein `TODO`:
- Übergangs-Animation in den Kampf (`SceneSwitcher.start_battle`)
- EP nach dem Sieg (`MonsterInstance.gain_exp`), bei Niederlage zum Heilpunkt statt nur heilen
- Rohling aus dem Inventar nehmen und verbrauchen (`CatchSystem.add_to_team`)
- Monster wechseln, Items, der Spieler kämpft selbst und Fusion (`MergeSystem`)
- Genauigkeit, Krits über Glück, Mehrfachtreffer einzeln werten
- Status (Schlaf, Paralyse) erhöht die Fangchance
- Bessere Gegner-KI (`EnemyAI.choose_move`)
