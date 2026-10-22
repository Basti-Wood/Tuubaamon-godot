extends StaticBody3D

## PLATZHALTER - Verschlossene Tür (Zelda-Stil): braucht einen kleinen Schlüssel dieses Dungeons
## oder einen Boss-Schlüssel. Kleine Schlüssel gelten nur im eigenen Dungeon.
## Schlüssel liegen in GameState, NICHT im Inventar (wie in Zelda).

@export var dungeon_id: String = ""        # z. B. "wald_dungeon"
@export var boss_door: bool = false        # braucht den Boss-Schlüssel statt eines kleinen
@export var opened_flag: String = ""       # Story-Flag, damit sie offen bleibt

func _ready() -> void:
	# TODO: if GameState.has_flag(opened_flag): offen anzeigen / queue_free()
	pass

func interact(_player: Node) -> void:
	# TODO:
	# if boss_door:
	#     if GameState.has_boss_key(dungeon_id): öffnen
	# elif GameState.get_small_keys(dungeon_id) > 0:
	#     GameState.use_small_key(dungeon_id); öffnen
	# else:
	#     DialogueBox.show_lines(["Verschlossen."])
	# Öffnen = Animation, GameState.set_flag(opened_flag), Kollision aus
	# Neu in GameState nötig: var dungeon_keys := {"wald_dungeon": {"small": 1, "boss": false}}
	pass
