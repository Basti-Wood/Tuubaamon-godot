extends Control
# Updated sound_options.gd - Now properly saves and loads settings via ConfigManager

@onready var master_slider = $VBoxContainer/Master
@onready var sound_slider = $VBoxContainer/Music
@onready var sfx_slider = $VBoxContainer/SFX

func _ready() -> void:
	print("=== Sound Options Loading ===")
	
	# Wait for ConfigManager if needed
	if ConfigManager.current_settings.is_empty():
		ConfigManager.settings_loaded.connect(_load_saved_volumes)
	else:
		_load_saved_volumes()

func _load_saved_volumes():
	"""Load saved volume levels from ConfigManager"""
	print("Loading saved audio settings...")
	
	# Load saved volume levels (ConfigManager stores as 0-100 percent)
	var master_volume = ConfigManager.get_master_volume_percent()
	var music_volume = ConfigManager.get_music_volume_percent()
	var sfx_volume = ConfigManager.get_sfx_volume_percent()
	
	print("Loaded volumes - Master: " + str(master_volume) + "%, Music: " + str(music_volume) + "%, SFX: " + str(sfx_volume) + "%")
	
	# Set slider values (signals are already connected in the scene file)
	master_slider.set_value_no_signal(master_volume)
	sound_slider.set_value_no_signal(music_volume)
	sfx_slider.set_value_no_signal(sfx_volume)
	
	print("✅ Audio settings loaded and UI updated")

func _on_master_value_changed(value: float) -> void:
	"""Handle master volume slider change"""
	print("Master volume changed to: " + str(value) + "%")
	ConfigManager.set_master_volume_percent(value)

func _on_sound_value_changed(value: float) -> void:
	"""Handle music volume slider change"""
	print("Music volume changed to: " + str(value) + "%")
	ConfigManager.set_music_volume_percent(value)

func _on_sfx_value_changed(value: float) -> void:
	"""Handle SFX volume slider change"""
	print("SFX volume changed to: " + str(value) + "%")
	ConfigManager.set_sfx_volume_percent(value)

func _on_exit_pressed() -> void:
	print("Exiting sound options...")
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")

# Debug function (can be removed in production)
func _debug_bus_volumes() -> void:
	for bus_idx in range(AudioServer.get_bus_count()):
		var bus_name = AudioServer.get_bus_name(bus_idx)
		var db = AudioServer.get_bus_volume_db(bus_idx)
		print("%s: %.2f dB" % [bus_name, db])
