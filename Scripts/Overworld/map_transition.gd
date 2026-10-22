extends Area3D

## PLATZHALTER - Ausgang/Tür, der in eine andere Map führt.
## In der Ziel-Map braucht es einen Marker3D mit dem Namen aus target_spawn.

@export_file("*.tscn") var target_map: String
@export var target_spawn: String = "start"

func _ready() -> void:
	# TODO: body_entered.connect(_on_body_entered)
	pass

func _on_body_entered(body: Node3D) -> void:
	# TODO: if body ist der Spieler: SceneSwitcher.go_to_map(target_map, target_spawn)
	pass
