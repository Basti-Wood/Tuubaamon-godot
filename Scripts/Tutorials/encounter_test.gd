extends Node2D

## Testszene für das Tutorial docs/tutorials/begegnungen-kampf-fangen.md:
## mit WASD ins grüne Feld (hohes Gras) laufen, bis ein Kampf startet.
## Die Bewegung hier ist nur ein Ersatz, bis der echte Spieler (player_controller.gd) fertig ist.

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	if GameState.party.is_empty():
		var starter: MonsterInstance = $Gras.encounter_table.roll()
		starter.nickname = "Starter"
		GameState.party.append(starter)

func _physics_process(_delta: float) -> void:
	player.velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * 120.0
	player.move_and_slide()
