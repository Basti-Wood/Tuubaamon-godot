extends Control

## Grafik-Einstellungen. Speichert über den ConfigManager.

@onready var window_settings_option = $"VBoxContainer/Window Settings"

func _ready() -> void:
	if ConfigManager.current_settings.is_empty():
		ConfigManager.settings_loaded.connect(_load_saved_graphics)
	else:
		_load_saved_graphics()

func _load_saved_graphics():
	if window_settings_option:
		window_settings_option.selected = ConfigManager.get_window_mode()

func _on_window_settings_item_selected(index: int) -> void:
	# Speichert und wendet sofort an
	ConfigManager.set_window_mode(index)

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")
