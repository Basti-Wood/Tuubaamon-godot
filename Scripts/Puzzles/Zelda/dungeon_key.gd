extends Area3D

## PLATZHALTER - Schlüssel zum Aufheben (kleiner Schlüssel oder Boss-Schlüssel).
## Kann direkt im Raum liegen oder erst erscheinen, wenn ein Rätsel gelöst ist
## (dann im PuzzleManager unter reward_on_solve eintragen bzw. von puzzle_chest.gd ausgeben).

@export var dungeon_id: String = ""
@export var is_boss_key: bool = false
@export var picked_flag: String = ""       # damit er nach dem Aufheben weg bleibt

func _ready() -> void:
	# TODO:
	# if GameState.has_flag(picked_flag): queue_free()
	# body_entered verbinden
	pass

func _on_body_entered(_body: Node3D) -> void:
	# TODO:
	# if _body ist der Spieler:
	#     if is_boss_key: GameState.give_boss_key(dungeon_id)
	#     else: GameState.add_small_key(dungeon_id)
	#     GameState.set_flag(picked_flag)
	#     Aufheb-Jingle, Sprite kurz über den Kopf halten, queue_free()
	pass
