extends Control




func _on_sound_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Options/Sound_Options.tscn")


func _on_graphic_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Options/Graphic_Settings.tscn")


func _on_control_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Options/input_settings.tscn")


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/main_menue.tscn")
