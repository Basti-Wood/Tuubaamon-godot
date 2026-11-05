# Goldener Van (Schnellreise) und Reiten

Brainstorm: Der goldene Van ist eine frühe Schnellreise zwischen den Stadtstaaten (Berlin, Hamburg, Bremen als Story-Ankerpunkte). Später schnellere Fortbewegung: Fahrrad, E-Scooter mit Akku, reitbare Monster.

## 1. Haltestellen freischalten

Jede Haltestelle ist ein Flag `van_<ort>`. Ein `Area2D` in der Stadt schaltet sie frei:

```gdscript
extends Area2D

@export var stop_id := "berlin"   # -> Flag "van_berlin"

func _ready() -> void:
	body_entered.connect(func(body):
		if body.is_in_group("player"):
			GameState.set_flag("van_" + stop_id))
```

## 2. Van-Menü

```gdscript
extends Control

## Liste aller Haltestellen. Freigeschaltete sind anklickbar.

## Haltestelle -> [Map-Pfad, Spawn-Name]
const STOPS := {
	"berlin":  ["res://Szene/Maps/berlin.tscn", "van"],
	"hamburg": ["res://Szene/Maps/hamburg.tscn", "van"],
	"bremen":  ["res://Szene/Maps/bremen.tscn", "van"],
}

@onready var list: VBoxContainer = $VBoxContainer

func _ready() -> void:
	for id in STOPS:
		var b := Button.new()
		b.text = id.capitalize()
		b.disabled = not GameState.has_flag("van_" + id)
		b.pressed.connect(_travel.bind(id))
		list.add_child(b)

func _travel(id: String) -> void:
	var target: Array = STOPS[id]
	# Map-Wechsel wie im Karten-Tutorial, z. B.:
	# SceneSwitcher.go_to_map(target[0], target[1])
	print("Reise nach ", target)
	queue_free()
```

Öffnen: Interaktion mit dem Van-NPC in jeder Stadt (`add_child(preload("res://Szene/UI/van_menu.tscn").instantiate())`).

## 3. Schneller laufen (Fahrrad, Scooter, Reiten)

Alle drei sind nur ein anderer Geschwindigkeitswert im Spieler-Script:

```gd
enum Mount { NONE, BIKE, SCOOTER, MONSTER }
var mount := Mount.NONE
var scooter_charge := 100.0
const SPEED := {Mount.NONE: 80.0, Mount.BIKE: 140.0, Mount.SCOOTER: 170.0, Mount.MONSTER: 160.0}

# in _physics_process:
var speed: float = SPEED[mount]
if mount == Mount.SCOOTER:
	scooter_charge -= delta * 2.0
	if scooter_charge <= 0.0:
		mount = Mount.NONE
velocity = input_dir * speed
```

Reiten: Beim Aufsteigen `$Sprite2D.texture` auf das Monster-Reitsprite wechseln. Ein Reit-Monster kann zusätzlich wie ein VM-Item Hindernisse erlauben (z. B. Wasser).
