extends Node

## PLATZHALTER - Speichern und Laden von Spielständen.
## Später als Autoload "SaveManager" eintragen.
## Einstellungen (Lautstärke, Tasten) speichert schon der ConfigManager, hier geht es nur um den Spielstand.

const SAVE_DIR := "user://saves/"

func save_game(slot: int) -> void:
	# TODO:
	# var data = {
	#     "version": 1,
	#     "player": GameState.player (Name, Level, Geld, Inventar),
	#     "party": [m.to_dict() for m in GameState.party],
	#     "box": ...,
	#     "story_flags": GameState.story_flags,
	#     "map": GameState.current_map, "spawn": GameState.spawn_point,
	# }
	# Datei SAVE_DIR + "slot_%d.json" % slot als JSON schreiben
	pass

func load_game(slot: int) -> bool:
	# TODO: JSON lesen, GameState füllen, MonsterInstance.from_dict() benutzen
	# danach SceneSwitcher.go_to_map(GameState.current_map, GameState.spawn_point)
	return false

func has_save(slot: int) -> bool:
	# TODO: return FileAccess.file_exists(SAVE_DIR + "slot_%d.json" % slot)
	return false
