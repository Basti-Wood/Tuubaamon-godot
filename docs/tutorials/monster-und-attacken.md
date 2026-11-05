# Tutorial: Monster und Attacken

Stand: 2026-11-05, Godot 4.7. Die Feld-Tabellen stehen in [ANLEITUNG.md](../ANLEITUNG.md) (Abschnitte 2 und 3). Hier geht es Schritt für Schritt an einem fertigen Beispiel: **Glimmi**, ein Licht-Monster mit zwei Attacken.

Beispieldateien:

- `Resources/Monsters/Glimmi.tres`
- `Resources/Moves/Lichtstrahl.tres` (1 Treffer)
- `Resources/Moves/Funkenregen.tres` (3 Treffer, jeder mit eigenem Timing)
- `Szene/DEBUg/monster_test.tscn` + `Scripts/DEBUG/monster_test.gd` (Test ohne Kampf)

---

## 1. Art und Exemplar

| | Klasse | Datei | Beispiel |
|---|---|---|---|
| **Art** (wie ein Pokédex-Eintrag) | `MonsterData` | `Resources/Monsters/*.tres` | "Glimmi": Typ, Basiswerte, Attacken pro Level |
| **Exemplar** (ein gefangenes Monster) | `MonsterInstance` | entsteht im Code | "Glimmi, Lv. 12, 30/41 KP, Spitzname Funki" |

Die `.tres` baust du im Inspector. `MonsterInstance` erzeugst du im Code, wenn ein Monster auftaucht oder gefangen wird.

---

## 2. Attacken anlegen

Zuerst die Attacken, damit du sie danach im Monster auswählen kannst.

1. In `Resources/Moves/` Rechtsklick auf `1TemplateMove.tres` → **Duplicate** → `Lichtstrahl.tres`.
2. Im Inspector: `MoveName` = Lichtstrahl, `MoveType` = LICHT, `AttackType` = SPECIAL, `Damage` = 60, `MaxPP` = 15, `Contact` aus.
3. Gruppe **Timing** aufklappen: `TimingHits` = `[0.8]`. Das heißt: 0,8 s nach Start der Animation prallt der Strahl auf, genau dann muss gedrückt werden.

**Mehrfachtreffer** (`Funkenregen.tres`):

| Feld | Wert | Warum |
|---|---|---|
| `TimingHits` | `[0.4, 0.7, 1.0]` | 3 Funken, 3 Drücke |
| `IsMultiHit` | an | jeder Druck ist ein eigener Treffer mit eigener Stufe |
| `MinHits` / `MaxHits` | 3 / 3 | immer 3 Treffer |
| `TimingWindowScale` | 1.2 | Fenster 20 % größer, weil 3 Drücke schwerer sind |
| `Damage` | 20 | pro Treffer, darum kleiner |

Ohne `IsMultiHit` zählen mehrere Drücke als **ein** Treffer, gewertet wird der Durchschnitt.

> Tipp: Die Zeiten in `TimingHits` liest du später aus der Animation ab (Frame des Aufpralls ÷ Frames pro Sekunde).

---

## 3. Monster anlegen

1. In `Resources/Monsters/` `1TemplateMonster.tres` duplizieren → `Glimmi.tres`.
2. **Identität:** `name` = Glimmi, `monster_id` = 1 (nie doppelt), `description`.
3. **Sprite:** `sprite` = Kampfbild. Bei 2D top-down wie Pokémon reicht ein Bild pro Monster (z. B. 64×64 px, Hintergrund transparent). Bis es Zeichnungen gibt, bleibt das DEBUG-Sprite drin.
4. **Typen:** `primary_type` = LICHT, `secondary_type` = NONE.
5. **Basiswerte** (Richtwert 40–120, Summe um 300–350 für eine erste Stufe):

| Wert | Feld | Glimmi |
|---|---|---|
| KP | `base_hp` | 45 |
| Angriff | `base_attack` | 40 |
| Verteidigung | `base_defense` | 45 |
| Sp.-Angriff | `base_special_attack` | 65 |
| Sp.-Verteidigung | `base_special_defense` | 55 |
| Initiative | `base_speed` | 60 |
| **Glück** (Krit-Chance) | `base_luck` | 70 |

6. **Fortschritt:** `base_exp_yield` = 50, `growth_rate` = FAST, `catch_rate` = 45.
7. **Attacken pro Level:** bei `level_up_moves` auf **+** → **New LevelUpMove** → `level` = 1, `move` = `Lichtstrahl.tres` reinziehen. Noch einer: `level` = 8, `move` = `Funkenregen.tres`.
8. `developer_notes`: welches Community-Mitglied die Vorlage ist.

---

## 4. Entwicklung

1. **Zuerst die Endstufe** anlegen, z. B. `Strahlo.tres` (höhere Basiswerte).
2. In `Glimmi.tres`: `evolves_into` = `Strahlo.tres`, `evolution_level` = 16.
3. Fertig. `MonsterInstance.level_up()` prüft das automatisch und ruft `evolve()` auf. Level, EP und Attacken bleiben, nur die Art wechselt.

`evolution_item` (Entwicklung per Item) ist noch nicht eingebaut, das kommt mit dem Item-System.

---

## 5. Monster im Code benutzen

`Scripts/Monster/monster_instance.gd` kann jetzt:

```gdscript
var glimmi := MonsterInstance.create(load("res://Resources/Monsters/Glimmi.tres"), 5)
glimmi.nickname = "Funki"

glimmi.get_max_hp()          # KP-Maximum: (2 * Basis * Level) / 100 + Level + 10
glimmi.get_stat("attack")    # andere Werte: (2 * Basis * Level) / 100 + 5
glimmi.get_stat("luck")      # "attack", "defense", "special_attack", "special_defense", "speed", "luck"
glimmi.current_hp -= 10      # Schaden

glimmi.gain_exp(500)         # levelt so oft wie nötig, lernt Attacken, entwickelt sich
glimmi.moves                 # max. 4 Attacken, glimmi.move_pp[i] = übrige AP
```

- `create()` gibt volle KP und die letzten 4 Attacken, die es bis zu seinem Level gelernt hätte (wie wilde Pokémon).
- Bei einer 5. Attacke fliegt im Moment die älteste raus. Später soll gefragt werden.
- Noch offen (TODO im Skript): Amulett-Bonus, Status, Speichern (`to_dict`/`from_dict`).

---

## 6. Testen

1. `Szene/DEBUg/monster_test.tscn` öffnen.
2. **F6** drücken (aktuelle Szene starten).
3. Im **Output** steht dann ungefähr:

```
Glimmi Lv.5  KP 19/19  ANG 9  GLÜCK 12  Attacken: ["Lichtstrahl"]
Glimmi Lv.9  KP 27/27  ANG 12  GLÜCK 17  Attacken: ["Lichtstrahl", "Funkenregen"]
  Lichtstrahl: Timing [0.8], Mehrfachtreffer: false
  Funkenregen: Timing [0.4, 0.7, 1.0], Mehrfachtreffer: true
```

Für dein eigenes Monster in `monster_test.gd` einfach den Pfad in `_ready()` tauschen.

---

## Neu in diesem Schritt

- Typ **LICHT** in `Enums.Type` (ganz am Ende, damit alte .tres nicht verrutschen). In der Typ-Tabelle (`type_chart.gd`) ist Licht noch neutral gegen alles.
- Wert **Glück** (`base_luck`) in `MonsterData`.
