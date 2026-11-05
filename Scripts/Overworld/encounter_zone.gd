extends Area2D
class_name EncounterZone

## Bereich mit hohem Gras / Höhle, in dem wilde Monster auftauchen.
## Als Kind der Map-Szene anlegen, CollisionShape2D über das Gras ziehen.
## Der Spieler muss in der Gruppe "player" sein.

const STEP_SIZE := 16.0   # Pixel pro Schritt (eine Kachel)

@export var encounter_table: EncounterTable
@export_range(0.0, 1.0) var chance_per_step: float = 0.1

var _player: Node2D
var _last_position := Vector2.ZERO
var _distance_walked := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = body
		_last_position = body.global_position

func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null

func _physics_process(_delta: float) -> void:
	if _player == null or encounter_table == null:
		return

	_distance_walked += _player.global_position.distance_to(_last_position)
	_last_position = _player.global_position
	if _distance_walked < STEP_SIZE:
		return

	_distance_walked = 0.0
	if randf() < chance_per_step:
		var wild := encounter_table.roll()
		if wild:
			SceneSwitcher.start_battle([wild])
