extends Control

func _ready():
	AudioPlayer.play_music_level()

func _on_resume_last_safe_pressed() -> void:
	if SaveManager.load_game(1) and GameState.current_map != "":
		get_tree().change_scene_to_file(GameState.current_map)
		# TODO: Spieler an GameState.spawn_point setzen (macht später der SceneSwitcher)

func _on_new_game_pressed() -> void:
	GameState.new_game()
	# TODO: Start-Map laden, z. B.
	#       SceneSwitcher.go_to_map("res://Szene/Maps/startdorf.tscn", "start")
	pass

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
