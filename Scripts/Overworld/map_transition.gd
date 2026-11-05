extends Area2D

## Ausgang/Tür, der in eine andere Map führt. Braucht ein CollisionShape2D als Kind.
## In der Ziel-Map braucht es einen Marker2D mit dem Namen aus target_spawn.

@export_file("*.tscn") var target_map: String
@export var target_spawn: String = "start"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneSwitcher.go_to_map(target_map, target_spawn)
