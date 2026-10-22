extends Camera3D

## PLATZHALTER - Kampfkamera: schräg von oben und von der Seite,
## sodass beide Seiten gleichzeitig zu sehen sind (wie Mario & Luigi / Paper Mario).

@export var default_position := Vector3(0, 4, 7)
@export var default_rotation_degrees := Vector3(-25, 0, 0)

func _ready() -> void:
	# TODO: position = default_position; rotation_degrees = default_rotation_degrees
	pass

func focus_on(target: Node3D, duration := 0.3) -> void:
	# TODO: mit Tween etwas näher an target heranfahren (für Angriffe, Fusion, Fangen)
	pass

func reset_view(duration := 0.3) -> void:
	# TODO: zurück auf default_position / default_rotation_degrees tweenen
	pass

func shake(strength := 0.2, duration := 0.15) -> void:
	# TODO: kurzes Wackeln bei starken Treffern ("Exzellent!")
	pass
