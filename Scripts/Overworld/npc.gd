extends CharacterBody3D

## PLATZHALTER - NPC oder Trainer in der Overworld.
## Gleicher Aufbau wie der Spieler: Sprite3D (Y-Billboard) + CollisionShape3D.

@export var npc_name: String = ""
@export_multiline var dialogue_lines: Array[String] = []
@export var is_trainer: bool = false
# TODO: @export var trainer_team: Array[MonsterInstance] = []
# TODO: @export var defeated_flag: String = ""      # Story-Flag, damit man nicht zweimal kämpft
# TODO: @export var sight_range: float = 4.0        # Trainer sieht den Spieler und läuft hin

func interact(player: Node) -> void:
	# TODO:
	# DialogueBox.show_lines(dialogue_lines)
	# await Dialog fertig
	# if is_trainer and not GameState.has_flag(defeated_flag):
	#     SceneSwitcher.start_battle(trainer_team, true)
	pass
