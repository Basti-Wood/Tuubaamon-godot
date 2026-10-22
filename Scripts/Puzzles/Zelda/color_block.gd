extends PuzzleElement

## PLATZHALTER - Block, der je nach Farbe hoch- oder runterfährt (rote/blaue Blöcke aus Zelda).
## Hängt in der Gruppe "puzzle_color_<farbe>" und wird von hit_switch.gd umgeschaltet.
## Aufbau: ColorBlock (Node3D, dieses Skript)
##           ├── MeshInstance3D (Würfel)
##           └── StaticBody3D + CollisionShape3D

@export var color: String = "rot"

func _ready() -> void:
	super()
	# TODO: add_to_group("puzzle_color_" + color)
	pass

func _apply_state(_animate: bool) -> void:
	# TODO:
	# AN  = oben: Kollision an, Mesh auf normale Höhe
	# AUS = unten: Kollision aus, Mesh im Boden versenken (Tween)
	pass
