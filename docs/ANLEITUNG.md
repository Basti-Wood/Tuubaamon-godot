# Tuubaamon: Wie füge ich etwas hinzu?

Diese Anleitung erklärt Schritt für Schritt, wie du neue Monster, Attacken, Items, Maps und mehr ins Spiel bringst.
Stand: 2026-10-22, Godot 4.7.

> **Wichtig vorweg**
> - Dateien immer **im Godot-Editor** verschieben oder umbenennen (Rechtsklick im FileSystem-Dock). Dann passt Godot alle Verweise automatisch an. Im Explorer verschieben macht Verweise kaputt.
> - Für neue Daten (Monster, Attacken, Items ...) gibt es in jedem Ordner eine Vorlage, deren Name mit `1` beginnt (z. B. `1TemplateMonster.tres`). Rechtsklick auf die Vorlage, **Duplicate**, neuen Namen geben, Werte im Inspector ausfüllen.
> - Dateien mit `PLATZHALTER` oben drin sind noch leer und enthalten nur TODOs.

---

## 1. Ordnerstruktur

```
Tuubaamon-godot/
├── Assets/               Bilder, Sounds, Musik, Tilesets, UI-Theme
│   ├── Audio/            Musik (.mp3/.ogg)
│   ├── DEBUG/            Test-Sprite und Test-Sound
│   ├── Sprites/          Sprites und Tilesets
│   └── UI/               main_theme.tres (Aussehen aller Menüs)
├── Resources/            Spieldaten als .tres (im Inspector bearbeitbar)
│   ├── Abilities/        Fähigkeiten
│   ├── Items/            Items
│   ├── Monsters/         Monster-Arten
│   ├── Moves/            Attacken
│   ├── Puzzles/          Level für Puzzlespiel-Rätsel (Bento, Schiebe-Puzzle ...)
│   └── StatusEffects/    Statuseffekte (Verbrennung, Gift ...)
├── Scripts/              GDScript-Code
│   ├── Abilities/ Item/ Monster/ Move/ StatusEffects/   Vorlagen-Klassen für die Resources
│   ├── Battle/           Kampf: BattleSystem, DamageCalculator, TypeChart, ActionCommand, Fusion
│   │   └── Prototype/    Timing-Prototyp (wird gerade getestet, nicht anfassen)
│   ├── Core/             GameState, SaveManager, SceneSwitcher (Platzhalter)
│   ├── DEBUG/            Debug-Kampfszene
│   ├── Enums/            Enums.gd: alle gemeinsamen Aufzählungen (Typen, Kategorien ...)
│   ├── Main menue/       Hauptmenü und Optionen
│   ├── Music/            AudioPlayer (Autoload)
│   ├── Overworld/        Spieler, Kamera, Gras, Türen, NPCs, VM-Hindernisse (Platzhalter)
│   ├── Puzzles/          Rätsel: Basis, Zelda/, Pokemon/, Minigame/ (Platzhalter, siehe Abschnitt 12)
│   ├── Player/           PlayerData
│   ├── UI/               Kampf-HUD, Team, Inventar, Dialog, Pause (Platzhalter)
│   └── ConfigManager.gd  Einstellungen speichern/laden (Autoload)
├── Szene/                Szenen (.tscn)
│   ├── DEBUg/            Debug-Kampfszene
│   ├── Music/            AudioPlayer-Szene
│   ├── Prototype/        Timing-Prototyp
│   └── main menue/       Hauptmenü, Optionen, Pausemenü
├── addons/               Editor-Plugin "Copy All Errors"
└── docs/                 Diese Anleitung und die Roadmap
```

Neue Szenen bitte so ablegen (Ordner beim ersten Mal im Editor anlegen):

| Was | Szene | Skript |
|---|---|---|
| Maps (Dörfer, Routen, Dungeons) | `Szene/Maps/<name>.tscn` | meist keins nötig |
| Spielerfigur, NPC-Vorlage | `Szene/Overworld/` | `Scripts/Overworld/` |
| Kampfszene | `Szene/Battle/battle_scene.tscn` | `Scripts/Battle/battle_scene.gd` |
| Menüs und HUD | `Szene/UI/` | `Scripts/UI/` |
| Puzzlespiel-Fenster (Bento, Schiebe-Puzzle ...) | `Szene/Puzzles/` | `Scripts/Puzzles/Minigame/` |

**Benennung:** Dateien in `snake_case` (z. B. `route_1.tscn`), Klassen in `PascalCase` (z. B. `MonsterData`). Bei alten Dateien mit anderen Namen ist das okay, die bleiben.

---

## 2. Neues Monster

Ein Monster besteht aus **einer .tres-Datei** in `Resources/Monsters/`. Sie benutzt das Skript `Scripts/Monster/MonsterTemplate.gd` (Klasse `MonsterData`).

1. In `Resources/Monsters/` Rechtsklick auf `1TemplateMonster.tres` → **Duplicate** → z. B. `Schnabelheld.tres`.
2. Datei anklicken und im **Inspector** ausfüllen:

| Feld | Bedeutung |
|---|---|
| `name` | Anzeigename |
| `monster_id` | eindeutige Nummer (wie Pokédex-Nummer). Nicht doppelt vergeben! |
| `description` | Text für den Monster-Index |
| `sprite` | Bild des Monsters. Für 2.5D: ein 2D-Bild, das später auf einem `Sprite3D` angezeigt wird |
| `idle/attack/hurt/defeat_animation` | Namen der Animationen (wenn es ein SpriteFrames gibt) |
| `sound_cry` | Ruf des Monsters |
| `primary_type`, `secondary_type` | Typen. `secondary_type` = `NONE`, wenn es nur einen Typ hat |
| `base_hp` ... `base_speed` | **Basiswerte**. Unbedingt setzen, sonst sind alle 1! Richtwert: 40–120 pro Wert |
| `base_exp_yield` | EP, die man beim Besiegen bekommt |
| `growth_rate` | Wie schnell es levelt (FAST, MEDIUM, SLOW) |
| `catch_rate` | 0–100, höher = leichter zu fangen |
| `abilities` | Fähigkeiten aus `Resources/Abilities/` |
| `level_up_moves` | Liste: auf **+** klicken → **New LevelUpMove** → `level` und `move` setzen |
| `evolves_into` | Monster-.tres der Entwicklung |
| `evolution_level` | Level der Entwicklung (`-1` = keine) |
| `evolution_item` | Item, das die Entwicklung auslöst (statt Level) |
| `developer_notes` | Notizen für euch, z. B. welches Community-Mitglied die Vorlage ist |

3. Testen: `Szene/DEBUg/debug_battlefield.tscn` öffnen und mit **F6** starten. Der Debug-Kampf lädt automatisch alle Monster aus `Resources/Monsters/`.

**Entwicklungslinie:** Zuerst die letzte Stufe anlegen, dann die vorherige, damit du `evolves_into` direkt auswählen kannst (Beispiel: `BisaTNT.tres` und `BisBomb.tres`).

---

## 3. Neue Attacke

Attacken sind .tres-Dateien in `Resources/Moves/` mit dem Skript `Scripts/Move/MoveTemplate.gd` (Klasse `MoveData`).

1. `1TemplateMove.tres` duplizieren, z. B. `Donnerschlag.tres`.
2. Im Inspector ausfüllen:

| Feld | Bedeutung |
|---|---|
| `MoveName`, `Description` | Name und Beschreibung (gerne deutsch, z. B. "Rankenhieb") |
| `MoveType` | Typ der Attacke (FIRE, WATER ...) |
| `AttackType` | PHYSICAL (nutzt Angriff), SPECIAL (nutzt Spezial-Angriff), STATUS (kein Schaden) |
| `Damage` | Stärke, Richtwert 30–120 |
| `Accuracy` | Genauigkeit 0–100 |
| `MaxPP` | Wie oft man sie einsetzen kann |
| `Target` | Wen sie trifft |
| `Priority` | -1, 0 oder 1. Höher = greift zuerst an |
| `InflictsStatus`, `status_effect`, `StatusChance` | Statuseffekt aus `Resources/StatusEffects/` mit Chance in % |
| `Contact` | Berührt das Ziel (wichtig für manche Fähigkeiten) |
| Gruppe **Quick Time Event** | Altes Timing-System. Das neue Timing (5 Stufen, immer aktiv) steckt in `Scripts/Battle/action_command.gd` und wird gerade im Prototyp getestet |
| Gruppe **Special Effects** | Rückstoß (`Recoil`), Absorbieren (`Drain`), Zurückschrecken, Krit-Bonus, Werte-Änderungen in Stufen (-6 bis +6), Mehrfachtreffer |
| `BattleText` | Eigener Text beim Einsetzen |

3. Die Attacke einem Monster geben: im Monster unter `level_up_moves` einen Eintrag mit Level und dieser Attacke anlegen.

---

## 4. Neues Item

Items liegen in `Resources/Items/` mit dem Skript `Scripts/Item/ItemTemplate.gd` (Klasse `ItemData`).

1. `1ItemTemplate.tres` duplizieren, z. B. `Hypertrank.tres`.
2. Wichtigste Felder:

| Feld | Bedeutung |
|---|---|
| `ItemName`, `ItemID`, `Description`, `Icon` | Name, eindeutige Nummer, Text, Bild |
| `Category` | CONSUMABLE (Tränke), BATTLE_ITEM (X-Angriff), CAPTURE (Schmuck/Amulett zum Fangen), EVOLUTION, KEY_ITEM (Story und VM-Items), HELD_ITEM |
| `UseContext` | BATTLE, OVERWORLD oder BOTH |
| `BuyPrice`, `SellPrice`, `MaxStack` | Shop und Inventar |
| `RestoresHP`, `RestoresHPPercent`, `RestoresPP` ... | Heilung |
| `CuresStatus`, `RevivesMonster` ... | Status heilen, wiederbeleben |
| `Boost...` | Werte im Kampf erhöhen (Stufen) |
| `CaptureRateBonus` | Für Fang-Items |
| `TriggersEvolution` | Für Entwicklungs-Items |
| `Held...` | Wirkung, wenn ein Monster es trägt |

**VM-Items** (Baum schneiden, Fels zerschlagen ...): Category `KEY_ITEM`. Das Hindernis in der Map bekommt das Skript `Scripts/Overworld/hm_obstacle.gd` und dieses Item als `required_item`.

**Schmuck/Amulette zum Fangen:** dafür gibt es die Klasse `AmuletData` (`Scripts/Item/amulet_data.gd`, noch Platzhalter). Sie erweitert `ItemData` um Fang-Bonus und Upgrade-Werte. Neue Amulett-Datei: im FileSystem Rechtsklick → **New Resource** → `AmuletData`.

---

## 5. Fähigkeiten und Statuseffekte

Genau wie oben, nur in anderen Ordnern:

- **Fähigkeit:** `Resources/Abilities/1AbilityTemplate.tres` duplizieren. `TriggerType` sagt, wann sie wirkt (immer, beim Einwechseln, bei wenig KP ...). Danach im Monster unter `abilities` eintragen.
- **Statuseffekt:** `Resources/StatusEffects/1StatusTemplate.tres` duplizieren. `MaxTurns = -1` heißt "bleibt bis geheilt". `DamagePerTurnPercent = 0.1` heißt 10 % KP Schaden pro Runde. Danach in einer Attacke unter `status_effect` eintragen.

---

## 6. Neue Map (2.5D)

Das Spiel ist **2.5D**: die Welt ist 3D, Figuren und Monster sind flache 2D-Sprites, die immer zur Kamera schauen (wie Paper Mario oder Octopath Traveler). Die Kamera schaut schräg von oben.

Die Skripte dafür sind noch Platzhalter. So wird eine Map aufgebaut, sobald sie fertig sind:

1. **Szene anlegen:** *Scene → New Scene*, Root-Node `Node3D`, speichern als `Szene/Maps/<name>.tscn` (z. B. `route_1.tscn`).
2. **Licht und Himmel:** `WorldEnvironment` und `DirectionalLight3D` hinzufügen (schräg von oben, Schatten an).
3. **Boden bauen**, eine der beiden Varianten:
   - **GridMap** (empfohlen): eine MeshLibrary mit Boden-, Gras-, Wasser- und Wegstücken bauen (die Grassland-Tiles aus `Assets/Sprites/TileSet/Grassland/` können als Texturen dienen) und die Map wie mit Lego-Steinen malen.
   - **Einfach:** `MeshInstance3D` mit einer `PlaneMesh` und Textur, dazu `StaticBody3D` + `CollisionShape3D`, damit man nicht durchfällt.
4. **Deko:** Bäume, Büsche, Schilder als `Sprite3D` (Billboard auf **Y-Billboard** stellen) oder als kleine 3D-Modelle. Bei `Sprite3D` unter *Flags* **Shaded** an und **Alpha Cut** auf *Discard* stellen, dann werfen sie Schatten und sehen nicht verschwommen aus.
5. **Spieler:** `Szene/Overworld/player.tscn` als Instanz einfügen (*Instantiate Child Scene*), dazu eine `Camera3D` mit `Scripts/Overworld/overworld_camera.gd`.
6. **Spawn-Punkte:** pro Eingang einen `Marker3D` mit sprechendem Namen (`start`, `von_route_1`, ...).
7. **Ausgänge:** `Area3D` + `CollisionShape3D` mit `Scripts/Overworld/map_transition.gd`. Im Inspector `target_map` (Ziel-Szene) und `target_spawn` (Name des Marker3D in der Ziel-Map) setzen.
8. **Hohes Gras:** `Area3D` + `CollisionShape3D` mit `Scripts/Overworld/encounter_zone.gd`. Dazu eine `EncounterTable` in `Resources/Encounters/` anlegen (welche Monster, welche Level, wie oft) und zuweisen.
9. **NPCs und Trainer:** `CharacterBody3D` + `Sprite3D` + `CollisionShape3D` mit `Scripts/Overworld/npc.gd`. Dialog-Zeilen im Inspector eintragen, für Trainer `is_trainer` an.
10. **Musik:** im Skript der Map oder beim Betreten `AudioPlayer.play_music_level("route_1.mp3")`.

Tipp für den Look: Kamera-Neigung ca. 30–40°, Figuren leicht größer als die Tiles, warmes Licht. Paper-Mario-Gefühl entsteht vor allem durch flache Figuren mit dickem Rand und weiche Schatten darunter.

---

## 7. Kampf (2.5D)

Der Kampf wird in einer eigenen 3D-Szene gezeigt, mit der Kamera **schräg von oben und von der Seite**, sodass man beide Seiten gleichzeitig sieht (wie Mario & Luigi).

- Kampf-Logik: `Scripts/Battle/battle_system.gd`, `damage_calculator.gd`, `type_chart.gd`, `merge_system.gd` (Fusion).
- Timing (5 Stufen, Angriff und Verteidigung): `Scripts/Battle/action_command.gd`.
- Neue Kampfszene (Platzhalter): `Scripts/Battle/battle_scene.gd`, `battle_camera.gd`, `enemy_ai.gd`, `catch_system.gd`, `Scripts/UI/battle_hud.gd`. Oben in `battle_scene.gd` steht, welche Nodes die Szene braucht.
- Zum Testen gibt es bis dahin `Szene/DEBUg/debug_battlefield.tscn` und den Timing-Prototyp `Szene/Prototype/timed_battle_prototype.tscn`.

---

## 8. Musik und Sounds

1. Datei (`.mp3` oder `.ogg`) nach `Assets/Audio/` kopieren.
2. Damit sie in Schleife läuft: Datei anklicken → **Import**-Tab → **Loop** an → **Reimport**. (Der AudioPlayer startet sonst am Ende einfach neu.)
3. Abspielen: `AudioPlayer.play_music_level("dateiname.mp3")`, stoppen: `AudioPlayer.play_music_stop()`.

Die Lautstärke regelt der Spieler im Optionsmenü (Bus "Music"). Sound-Effekte auf den Bus "SFX" legen.

---

## 9. Neuer Typ oder neuer Enum-Wert

Alle gemeinsamen Aufzählungen stehen in `Scripts/Enums/Enums.gd` und werden überall als `Enums.Type.FIRE`, `Enums.ItemCategory.KEY_ITEM` usw. benutzt.

> **Achtung:** .tres-Dateien speichern Enum-Werte als **Zahl** (z. B. `primary_type = 5` für GRASS). Neue Werte darum **immer ans Ende** eines Enums setzen. Wenn du einen Wert in die Mitte schiebst, verrutschen alle gespeicherten Monster und Attacken.

Neuer **Typ** (z. B. `LIGHT` für den Licht-Typ):
1. In `Enums.gd` ans Ende von `enum Type` setzen.
2. In `Scripts/Battle/type_chart.gd` eintragen: in `TYPE_EFFECTIVENESS` (was er trifft und was ihn trifft), in `type_to_string()` und in `get_type_color()`.

---

## 10. Menüs und Aussehen

- Alle Menüs benutzen das Theme `Assets/UI/main_theme.tres` (Farben, Schriftgröße, Buttons). Doppelklick darauf öffnet den Theme-Editor. Eine Änderung dort wirkt in allen Menüs.
- Neues Menü: Root-Node `Control`, im Inspector unter *Theme* `main_theme.tres` auswählen, als ersten Kind-Node einen `ColorRect` (Vollbild) als Hintergrund.
- Neue Taste (z. B. "menu"): *Projekt → Projekteinstellungen → Input Map* anlegen, dann in `Scripts/Main menue/input_settings.gd` (`input_actions`) und in `Scripts/ConfigManager.gd` (`default_settings.input`) eintragen, damit sie im Optionsmenü auftaucht.

---

## 11. Platzhalter fertig bauen

Diese Dateien enthalten nur TODOs und Pseudocode. Empfohlene Reihenfolge:

1. `Scripts/Monster/monster_instance.gd` (ein gefangenes Monster mit Level, KP, Attacken)
2. `Scripts/Core/game_state.gd` + als Autoload eintragen
3. `Scripts/Overworld/player_controller.gd` + `overworld_camera.gd` + erste Map
4. `Scripts/Core/scene_switcher.gd` + `Scripts/Overworld/encounter_zone.gd`
5. `Scripts/Battle/battle_scene.gd` (+ Kamera, HUD, KI) auf Basis von BattleSystem und ActionCommand
6. `Scripts/Battle/catch_system.gd` + `Scripts/Item/amulet_data.gd`
7. Menüs (`Scripts/UI/`), `Scripts/Core/save_manager.gd`, NPCs, VM-Hindernisse

Autoload eintragen: *Projekt → Projekteinstellungen → Globals → Autoload*, Skript auswählen, Namen vergeben (z. B. `GameState`).

Mehr zum Plan steht in `docs/ROADMAP.md`, die Spielregeln in den Design-Notizen (Obsidian-Vault bzw. `design/spielmechaniken.md`).

---

## 12. Rätsel

Alle Rätsel-Skripte liegen in `Scripts/Puzzles/` und sind noch **Platzhalter** (TODOs und Pseudocode). Es gibt drei Arten:

| Art | Ordner | Was drin ist |
|---|---|---|
| **Zelda-Stil** (Dungeon-Räume) | `Scripts/Puzzles/Zelda/` | Bodenschalter, Kristallschalter, rote/blaue Blöcke, Schiebeblock, Tür/Brücke/Treppe, verschlossene Tür, Schlüssel, Fackel, Truhe, die beim Lösen erscheint |
| **Pokémon-Stil** (auf dem Boden) | `Scripts/Puzzles/Pokemon/` | Stärke-Fels (braucht ein VM-Item), Loch für Felsen, Eisboden zum Rutschen, Pfeil-/Drehfelder, brüchiger Boden |
| **Puzzlespiel** (eigenes Fenster) | `Scripts/Puzzles/Minigame/` | Bento-Rätsel (Stücke in eine Box legen), Schiebe-Puzzle, Lichter aus, dazu das Overworld-Objekt, das sie öffnet |

### So hängt alles zusammen

- **`PuzzleElement`** (`puzzle_element.gd`) ist die Basis fast aller Teile. Jedes Teil ist **AN** oder **AUS**. Schalter, Fackeln usw. melden, wenn sie umschalten. Türen, Brücken und Truhen hören zu: im Inspector bei `listens_to` die Schalter eintragen und bei `condition` wählen, ob **ALLE**, **EINER** oder **KEINER** an sein muss.
- **`PuzzleManager`** (`puzzle_manager.gd`) kommt einmal pro Rätsel-Raum rein. Er weiß, wann das Rätsel gelöst ist (`goal_elements`), spielt den Lösungs-Sound, schaltet Belohnungen frei (`reward_on_solve`), speichert "gelöst" als Story-Flag in `GameState` und kann den Raum zurücksetzen.
- **`PuzzleGrid`** (`puzzle_grid.gd`) braucht man für alles, was auf Kacheln einrastet (Blöcke, Felsen, Eis, Drehfelder). Es rechnet Weltposition in Felder um und weiß, welche Felder frei sind.

### Beispiel: zwei Schalter öffnen eine Tür (Zelda-Stil)

```
Raum_3 (Node3D)
├── PuzzleManager         puzzle_id = "wald_dungeon_raum_3", goal_elements = [Tür]
├── PuzzleGrid            Größe des Raums
├── Schalter_A            floor_switch.gd, needs_heavy an (nur ein Block drückt ihn)
├── Schalter_B            floor_switch.gd
├── Block                 pushable_block.gd, grid = PuzzleGrid
└── Tür                   puzzle_door.gd, listens_to = [Schalter_A, Schalter_B], condition = ALLE
```

### Neues Puzzlespiel-Rätsel (z. B. Bento)

1. In `Resources/Puzzles/` die Vorlage `1GridPuzzleTemplate.tres` duplizieren und ausfüllen: Größe, gesperrte Felder (Form der Box), Stücke, Sterne-Grenzen, Hinweis.
2. Stücke sind `PuzzlePieceData`-Resources: die Form als Liste von Feldern, z. B. L-Form `(0,0) (0,1) (0,2) (1,2)`.
3. In der Map ein Objekt mit `Scripts/Puzzles/Minigame/puzzle_terminal.gd` aufstellen (Steintafel, Tisch ...), `puzzle_scene` (z. B. `Szene/Puzzles/bento_puzzle.tscn`) und das Level zuweisen.
4. Weil das Terminal selbst ein `PuzzleElement` ist, kann es wie ein Schalter eine Tür öffnen.

Mit derselben Bento-Logik gehen auch die **zerbrochenen Steinplatten** in den Story-Ruinen und später vielleicht das **Einsetzen von Schmucksteinen**. Die Sterne (`star_moves`) sind für den optionalen **Puzzle-Dungeon mit 3 Sternen** gedacht.

### Neue Rätselart bauen

- **Teil in der Welt** (Hebel, Spiegel, Druckplatte ...): neues Skript mit `extends PuzzleElement`, `_apply_state()` überschreiben (wie sieht AN/AUS aus?) und `set_active()` aufrufen, wenn der Spieler etwas tut.
- **Neues Puzzlespiel** (Sokoban, Rohre drehen, Memory ...): neues Skript mit `extends GridPuzzle`, die Funktionen unter "Von Unterklassen überschreiben" ausfüllen. Züge zählen, Rückgängig, Sterne und Schließen macht die Basis.

### Was in GameState noch dazukommen muss

- Story-Flags für gelöste Rätsel (`"puzzle_" + puzzle_id`) und beste Sterne.
- Dungeon-Schlüssel getrennt vom Inventar, z. B. `dungeon_keys = {"wald_dungeon": {"small": 1, "boss": false}}` (siehe `locked_door.gd`).
- Für Puzzlespiele zwei neue Tasten in der Input Map: `rotate` (Teil drehen) und `undo` (Rückgängig).

Reihenfolge zum Fertigbauen: `puzzle_element.gd` → `puzzle_manager.gd` → `floor_switch.gd` + `puzzle_door.gd` (erstes Rätsel) → `puzzle_grid.gd` + `pushable_block.gd` → der Rest nach Bedarf. Voraussetzung ist, dass `GameState` und der Spieler aus Abschnitt 11 laufen.
