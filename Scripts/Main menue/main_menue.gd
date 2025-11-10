extends Control

func _ready():
	AudioPlayer.play_music_level()

func _on_resume_last_safe_pressed() -> void:
	pass # Replace with function body.


func _on_new_game_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
