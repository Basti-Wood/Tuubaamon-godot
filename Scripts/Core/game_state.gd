extends Node

## Autoload "GameState": globaler Spielzustand: Spieler, Team, Story-Fortschritt, aktuelle Map.
## Zum Teil noch PLATZHALTER (TODOs).

const MAX_PARTY := 6

var party: Array[MonsterInstance] = []
var box: Array[MonsterInstance] = []       # Monster, die nicht im Team sind

# TODO: var player: PlayerData
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
