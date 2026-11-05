extends CharacterBody2D

## Spielfigur in der Overworld: 2D von oben, läuft Feld für Feld wie in Pokémon.
## Szene: Szene/Player/Player.tscn  (Anleitung: docs/tutorials/spieler-und-npcs.md)

signal stepped   ## nach jedem fertigen Schritt (z. B. für hohes Gras)

const TILE := 16
@export var walk_time := 0.2   ## Sekunden pro Feld

var facing := Vector2.DOWN
var can_move := true            ## false = Spieler steht still (Trainer läuft her, Kampf ...)
var is_moving := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $InteractRay

func _ready() -> void:
	add_to_group("player")
	position = (position / TILE).floor() * TILE + Vector2.ONE * TILE / 2   # genau auf Feldmitte

func _physics_process(_delta: float) -> void:
	if is_moving or not can_move or DialogueBox.is_open:
		return
	var dir := _input_dir()
	if dir == Vector2.ZERO:
		play_anim("idle")
		return
	facing = dir
	ray.target_position = facing * TILE
	if test_move(global_transform, dir * TILE):   # Wand oder NPC im Weg: nur umdrehen
		play_anim("idle")
		return
	is_moving = true
	play_anim("walk")
	var tween := create_tween()
	tween.tween_property(self, "position", position + dir * TILE, walk_time)
	await tween.finished
	is_moving = false
	stepped.emit()
	get_tree().call_group("trainers", "check_sight", self)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or is_moving or not can_move or DialogueBox.is_open:
		return
	ray.force_raycast_update()
	var target := ray.get_collider()
	if target and target.has_method("interact"):
		get_viewport().set_input_as_handled()   # sonst blättert dieselbe Taste gleich die Textbox weiter
		target.interact(self)

func _input_dir() -> Vector2:
	if Input.is_action_pressed("move_up"): return Vector2.UP
	if Input.is_action_pressed("move_down"): return Vector2.DOWN
	if Input.is_action_pressed("move_left"): return Vector2.LEFT
	if Input.is_action_pressed("move_right"): return Vector2.RIGHT
	return Vector2.ZERO

## Spielt z. B. "walk_left" oder "idle_up", falls die Animation existiert.
func play_anim(kind: String) -> void:
	var anim := kind + "_" + dir_name(facing)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

static func dir_name(dir: Vector2) -> String:
	match dir:
		Vector2.UP: return "up"
		Vector2.LEFT: return "left"
		Vector2.RIGHT: return "right"
	return "down"
