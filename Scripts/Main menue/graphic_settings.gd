extends Control
# Updated graphic_settings.gd - Now properly saves and loads settings via ConfigManager

@onready var window_settings_option = $"VBoxContainer/Window Settings"

func _ready() -> void:
	print("=== Graphics Settings Loading ===")
	
	# Wait for ConfigManager if needed
	if ConfigManager.current_settings.is_empty():
		ConfigManager.settings_loaded.connect(_load_saved_graphics)
	else:
		_load_saved_graphics()

func _load_saved_graphics():
	"""Load saved graphics settings from ConfigManager"""
	print("Loading saved graphics settings...")
	
	# Load saved window mode
	var saved_window_mode = ConfigManager.get_window_mode()
	print("Loaded window mode: " + str(saved_window_mode))
	
	# Set the option button to match saved setting (without triggering signal)
	if window_settings_option:
		window_settings_option.selected = saved_window_mode
		print("Set window option to index: " + str(saved_window_mode))
	
	print("✅ Graphics settings loaded and UI updated")

func _on_window_settings_item_selected(index: int) -> void:
	"""Handle window mode selection change"""
	print("Window mode changed to index: " + str(index))
	
	# Save the setting via ConfigManager (this also applies it immediately)
	ConfigManager.set_window_mode(index)
	
	print("✅ Window mode setting saved and applied")

func _on_exit_pressed() -> void:
	print("Exiting graphics options...")
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")
