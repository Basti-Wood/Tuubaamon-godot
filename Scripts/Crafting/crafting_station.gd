extends Area2D
class_name CraftingStation

## Werkstatt in der Overworld. Spieler stellt sich davor und drückt "interact".
## Braucht eine CollisionShape2D als Kind.

@export var recipes: Array[CraftingRecipe] = []
@export var menu: CraftingMenu
## Inventar { ItemData: Anzahl }. Später durch das echte Inventar (GameState) ersetzen.
var bag: Dictionary = {}

var _player_near := false

func _ready() -> void:
	body_entered.connect(func(body): _player_near = body is CharacterBody2D)
	body_exited.connect(func(_body): _player_near = false)

func _unhandled_input(event: InputEvent) -> void:
	if _player_near and event.is_action_pressed("interact") and menu and not menu.visible:
		menu.open(recipes, bag)
		get_viewport().set_input_as_handled()
