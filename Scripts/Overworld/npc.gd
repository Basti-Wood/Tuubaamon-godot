extends CharacterBody2D

## NPC oder Trainer. Szene: Szene/NPCs/Human/Template_Human.tscn
## Ansprechen: Spieler steht davor und drückt "interact".
## Trainer: sieht den Spieler in Blickrichtung, läuft hin, redet, Kampf.

const TILE := 16

@export var npc_name := ""
@export_multiline var dialogue_lines: Array[String] = ["Hallo!"]
@export var facing := Vector2.DOWN
@export_group("Trainer")
@export var is_trainer := false
@export var sight_range := 4                       ## in Feldern
@export_multiline var defeated_lines: Array[String] = ["Du bist stark!"]
# TODO: @export var trainer_team: Array[MonsterInstance] = []

var defeated := false     # TODO: später GameState.set_flag(...), damit es gespeichert wird
var _busy := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sight: RayCast2D = $SightRay

func _ready() -> void:
	position = (position / TILE).floor() * TILE + Vector2.ONE * TILE / 2
	_look(facing)
	if is_trainer:
		add_to_group("trainers")

## Wird vom Spieler nach jedem Schritt aufgerufen.
func check_sight(player: Node2D) -> void:
	sight.force_raycast_update()
	if not defeated and not _busy and sight.get_collider() == player:
		_challenge(player)

func interact(player: Node2D) -> void:
	if _busy:
		return
	_look((player.global_position - global_position).normalized().round())
	if is_trainer and not defeated:
		_challenge(player)
	else:
		await DialogueBox.show_lines(defeated_lines if defeated else dialogue_lines, npc_name)
		_look(facing)

func _challenge(player: Node2D) -> void:
	_busy = true
	player.can_move = false
	# Bis vor den Spieler laufen
	var steps := int(global_position.distance_to(player.global_position) / TILE) - 1
	_play("walk")
	for i in steps:
		var tween := create_tween()
		tween.tween_property(self, "position", position + sight.target_position.normalized() * TILE, 0.2)
		await tween.finished
	_play("idle")
	await DialogueBox.show_lines(dialogue_lines, npc_name)
	# TODO: await SceneSwitcher.start_battle(trainer_team, true) und nur bei Sieg defeated setzen
	print("Kampf gegen ", npc_name, " startet hier")
	defeated = true
	player.can_move = true
	_busy = false

func _look(dir: Vector2) -> void:
	sight.target_position = dir * TILE * sight_range
	var anim := "idle_" + _dir_name(dir)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

func _play(kind: String) -> void:
	var anim := kind + "_" + _dir_name(sight.target_position.normalized())
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

func _dir_name(dir: Vector2) -> String:
	match dir:
		Vector2.UP: return "up"
		Vector2.LEFT: return "left"
		Vector2.RIGHT: return "right"
	return "down"
