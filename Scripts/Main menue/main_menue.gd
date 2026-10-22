extends Control

func _ready():
	AudioPlayer.play_music_level()

func _on_resume_last_safe_pressed() -> void:
	# TODO: SaveManager.load_game(slot) und danach in die gespeicherte Map wechseln
	#       (siehe Scripts/Core/save_manager.gd). Button ausblenden, wenn es keinen Spielstand gibt.
	pass

func _on_new_game_pressed() -> void:
	# TODO: GameState zurücksetzen und die Start-Map laden, z. B.
	#       SceneSwitcher.go_to_map("res://Szene/Maps/startdorf.tscn", "start")
	pass

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
