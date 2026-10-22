extends PuzzleElement

## PLATZHALTER - Bodenschalter (Zelda-Stil).
## Geht AN, wenn der Spieler, ein Block oder ein Fels draufsteht.
## Aufbau: FloorSwitch (Node3D, dieses Skript)
##           ├── Sprite3D (Schalter oben / gedrückt, flach auf dem Boden, KEIN Billboard)
##           └── Area3D + CollisionShape3D (flache Box)

@export var needs_heavy: bool = false   # true = nur Block/Fels drückt ihn, der Spieler ist zu leicht
@export var stays_pressed: bool = false # true = einmal gedrückt, bleibt unten

# TODO: var _bodies_on_top: Array[Node3D] = []

func _ready() -> void:
	super()
	# TODO: Area3D body_entered / body_exited verbinden
	pass

func _on_body_entered(_body: Node3D) -> void:
	# TODO:
	# if needs_heavy and _body ist der Spieler: return
	# _bodies_on_top.append(_body); set_active(true)
	pass

func _on_body_exited(_body: Node3D) -> void:
	# TODO:
	# _bodies_on_top.erase(_body)
	# if _bodies_on_top.is_empty() and not stays_pressed: set_active(false)
	pass

func _apply_state(_animate: bool) -> void:
	# TODO: Sprite auf "gedrückt" wechseln, Klick-Sound
	pass
