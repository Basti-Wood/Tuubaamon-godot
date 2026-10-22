extends Camera3D

## PLATZHALTER - Kamera für die Overworld im 2.5D-Stil.
## Schaut schräg von oben (ähnlich Paper Mario / Octopath), folgt dem Spieler weich.

@export var target_path: NodePath
@export var offset := Vector3(0, 6, 8)      # Höhe und Abstand hinter dem Spieler
@export var follow_speed: float = 5.0

func _process(delta: float) -> void:
	# TODO:
	# var target := get_node(target_path)
	# global_position = global_position.lerp(target.global_position + offset, follow_speed * delta)
	# look_at(target.global_position)   # oder feste Neigung von ca. -35° auf rotation_degrees.x
	# Grenzen der Map beachten (Kamera nicht über den Rand fahren lassen)
	pass
