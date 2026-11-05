# Später: Entwicklungen, Delta-Formen, Battle Tower, Easter Eggs

Kleine Rezepte für Ideen, die später kommen. Erst bauen, wenn der Kern läuft („Spiel nicht überpacken“).

## 1. Entwicklungen (z. B. Lachsy-Reihe: Latzi → Lamlachsi → Minolachsi)

In `MonsterData` (`Scripts/Monster/MonsterTemplate.gd`):

```gd
@export var evolves_into: MonsterData
@export var evolution_level := 0
```

In `MonsterInstance.level_up()`:

```gd
if species.evolves_into and level >= species.evolution_level:
	species = species.evolves_into
	# Animation / Text "Latzi entwickelt sich zu Lamlachsi!"
```

## 2. Delta-Formen (unsere „Shinys“)

Seltene Variante mit anderem Typ und anderer Farbe. Beim Erzeugen eines wilden Monsters würfeln:

```gd
@export var is_delta := false   # in MonsterInstance

# beim Spawnen
m.is_delta = randf() < 1.0 / 512.0
```

`MonsterData` bekommt `@export var delta_types: Array[int]` und `@export var delta_sprite: Texture2D`. Überall, wo Typ oder Sprite gelesen wird, `is_delta` beachten.

## 3. Battle Tower / Roguelike

Brainstorm: Mit einem Monster rein, unterwegs fangen und kämpfen, Länge einstellbar, gefangene Monster darf man evtl. behalten.

```gdscript
extends Node
class_name TowerRun

var floors_total := 10
var current_floor := 0
var run_party: Array = []   # eigene Kopie, das echte Team bleibt unberührt

func start(starter, length: int) -> void:
	floors_total = length
	current_floor = 0
	run_party = [starter.duplicate(true)]

func next_floor() -> String:
	current_floor += 1
	if current_floor > floors_total:
		return "ende"
	# Jeder 3. Stock ein Trainer, sonst eine Fang-Begegnung
	return "trainer" if current_floor % 3 == 0 else "wild"
```

Gegner-Level `= 5 + current_floor * 3`. Am Ende: `GameState.box.append(...)` für behaltene Monster.

## 4. Easter Eggs

Einfach Flags + versteckte Objekte (siehe Story-Tutorial):

- **Goldener Van** in der Ruine: Objekt mit Wahrnehmungs-Check, gibt den Van frei (`GameState.set_flag("van_freigeschaltet")`).
- **Shaymin-Anspielung**: ein seltenes Wildmonster nur auf einer Blumenwiese (Begegnungstabelle mit Gewicht 1).
- **Bereits gelöste Ruine**: Dungeon-Szene, in der alle Rätsel-Elemente schon im gelösten Zustand starten.
- **Kriegsbriefe** (Ömers Hintergrund): Untersuchbare Objekte, setzen `brief_1` … `brief_n`. Alle gefunden → Zusatzszene.
- **Krankenschwester mit Gips**: NPC, der nur sichtbar ist, solange das Center geschlossen ist (Flag-Sichtbarkeit aus dem Story-Tutorial).
