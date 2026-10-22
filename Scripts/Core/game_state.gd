extends Node

## PLATZHALTER - noch nicht als Autoload eingetragen.
## Globaler Spielzustand: Spieler, Team, Story-Fortschritt, aktuelle Map.
## Später in Projekt > Projekteinstellungen > Globals als Autoload "GameState" eintragen.

# TODO: var player: PlayerData
# TODO: var party: Array[MonsterInstance] = []      # max. 6 (siehe design/spielmechaniken.md)
# TODO: var box: Array[MonsterInstance] = []        # Monster, die nicht im Team sind
# TODO: var story_flags: Dictionary = {}            # z. B. {"arena_1_besiegt": true}
# TODO: var current_map: String = ""                # res://-Pfad der aktuellen Map
# TODO: var spawn_point: String = ""                # Name des Spawn-Markers in der Map
# TODO: var unlocked_fusion: bool = false           # Fusion wird durch die Story freigeschaltet

func new_game() -> void:
	# TODO:
	# player = PlayerData.new()
	# party.clear(); box.clear(); story_flags.clear()
	# current_map = START_MAP; spawn_point = "start"
	pass

func set_flag(flag: String, value := true) -> void:
	# TODO: story_flags[flag] = value
	pass

func has_flag(flag: String) -> bool:
	# TODO: return story_flags.get(flag, false)
	return false
