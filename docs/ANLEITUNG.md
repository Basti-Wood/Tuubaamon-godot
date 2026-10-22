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
| Gruppe **Timing** | Wann gedrückt werden muss, passend zur Animation. Siehe unten "Timing einstellen" |
| Gruppe **Quick Time Event (alt)** | Altes System, nur noch für den DEBUG-Kampf. Für neue Attacken ignorieren |
| Gruppe **Special Effects** | Rückstoß (`Recoil`), Absorbieren (`Drain`), Zurückschrecken, Krit-Bonus, Werte-Änderungen in Stufen (-6 bis +6), Mehrfachtreffer |
| `BattleText` | Eigener Text beim Einsetzen |

3. Die Attacke einem Monster geben: im Monster unter `level_up_moves` einen Eintrag mit Level und dieser Attacke anlegen.

### Timing einstellen

Jede Attacke hat ein Timing mit 5 Stufen (Schlecht, Okay, Gut, Sehr gut, Exzellent), auch Status-Attacken. Wann gedrückt werden muss, stellst du pro Attacke in der Gruppe **Timing** ein:

| Feld | Bedeutung |
|---|---|
| `TimingHits` | Liste der Aufprall-Zeitpunkte in **Sekunden ab Start der Animation**. Ein Eintrag = ein Tastendruck |
| `TimingWindowScale` | Wie großzügig die Zeitfenster bei dieser Attacke sind. 1 = normal, 1.5 = leichter, 0.7 = schwerer |

Beispiele aus dem Projekt:

| Attacke | `TimingHits` | Was passiert |
|---|---|---|
| Kratzer | `[0.7]` | Ein Druck, Aufprall nach 0,7 s |
| Feuer Peitsche | `[0.55, 1.05]` | Ausholen und Peitschenknall, zwei Drücke |
| Rankenhieb | `[0.6, 0.85, 1.05]` | Mehrfachtreffer, drei Peitschenhiebe |

So passt du das Timing an eine Animation an:

1. Animation im AnimationPlayer öffnen und die Zeitleiste bis zu dem Frame schieben, in dem die Attacke trifft. Die Zeit oben in der Zeitleiste (z. B. `0.85`) ist dein Wert.
2. Für jeden weiteren Treffer genauso, dann alle Zeiten in `TimingHits` eintragen (Reihenfolge ist egal, sie werden sortiert).
3. Im Timing-Prototyp testen (`Szene/Prototype/timed_battle_prototype.tscn`, **F6**). Der Ring schließt sich genau zu deinen Zeitpunkten. Im Kampf-Log steht, wie viele Millisekunden du zu früh (−) oder zu spät (+) warst. Bist du immer z. B. +40 ms daneben, obwohl es sich richtig anfühlt, den Wert um 0.04 erhöhen.

Regeln:

- **Mehrfachtreffer** (`IsMultiHit` an): jeder Eintrag ist ein eigener Treffer mit eigener Stufe und eigenem Schaden. Die Anzahl der Treffer ist die Anzahl der Einträge.
- **Sonst** zählt der Durchschnitt aller Drücke für den einen Treffer. So kann eine starke Attacke z. B. erst ein Ausholen und dann den Schlag abfragen.
- Beim **Verteidigen** gelten dieselben Zeitpunkte, denn du reagierst auf dieselbe Animation des Gegners.
- Bisher gibt es nur Platzhalter-Animationen im Prototyp (Sprung, Ausholen, Zuschlagen), die sich nach `TimingHits` richten. Mit echten Animationen ist es umgekehrt: Die Animation ist fest, und du stellst `TimingHits` auf sie ein.

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
- Timing (5 Stufen, Angriff und Verteidigung): `Scripts/Battle/action_command.gd`. Die Zeitpunkte kommen aus jeder Attacke (`TimingHits`, siehe Kapitel 3).
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
