extends Node
# ConfigManager.gd - Centralized settings management system
# This should be added as an Autoload/Singleton in Project Settings

signal settings_loaded
signal settings_saved
signal setting_changed(category: String, key: String, value)

const CONFIG_FILE_PATH = "user://config/settings.json"
const CONFIG_DIR_PATH = "user://config/"

# Default settings structure
var default_settings = {
	"input": {
		"move_up": null,
		"move_down": null,
		"move_left": null,
		"move_right": null,
		"jump": null,
		"interact": null,
		"pause": null
	},
	"graphics": {
		"window_mode": 0,  # 0=Windowed, 1=Borderless, 2=Fullscreen
		"resolution_width": 1920,
		"resolution_height": 1080,
		"vsync_enabled": true,
		"fps_limit": 60,
		"quality_preset": "medium",  # low, medium, high, ultra
		"shadows_enabled": true,
		"anti_aliasing": 1,  # 0=Off, 1=FXAA, 2=MSAA2x, 3=MSAA4x
		"texture_quality": 1.0,  # 0.5=Low, 1.0=Medium, 2.0=High
		"render_scale": 1.0,
		"bloom_enabled": true,
		"screen_space_reflections": false
	},
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"voice_volume": 1.0,
		"audio_device": "Default",
		"mute_when_unfocused": false
	},
	"gameplay": {
		"mouse_sensitivity": 1.0,
		"auto_save_enabled": true,
		"auto_save_interval": 300,  # seconds
		"subtitles_enabled": true,
		"language": "en"
	},
	"accessibility": {
		"colorblind_support": false,
		"high_contrast": false,
		"large_text": false,
		"screen_shake": true
	}
}

# Current settings (loaded from file or defaults)
var current_settings = {}

func _ready():
	print("=== ConfigManager Initializing ===")
	_ensure_config_directory_exists()
	_load_project_input_defaults()
	load_settings()
	print("=== ConfigManager Ready ===")

func _ensure_config_directory_exists():
	"""Ensure the config directory exists"""
	if not DirAccess.dir_exists_absolute(CONFIG_DIR_PATH):
		DirAccess.open("user://").make_dir_recursive("config")
		print("Created config directory: " + CONFIG_DIR_PATH)

func _load_project_input_defaults():
	"""Load default input mappings from project settings"""
	print("Loading project input defaults...")
	
	for action in default_settings.input.keys():
		if InputMap.has_action(action):
			# Try to get from project settings first
			var project_setting_name = "input/" + action
			if ProjectSettings.has_setting(project_setting_name):
				var setting_value = ProjectSettings.get_setting(project_setting_name)
				if setting_value is Dictionary and setting_value.has("events") and setting_value["events"].size() > 0:
					default_settings.input[action] = _input_event_to_dict(setting_value["events"][0])
					print("✓ Loaded project default for " + action)
				else:
					print("✗ Invalid project setting structure for " + action)
			else:
				# Fallback to current InputMap
				var events = InputMap.action_get_events(action)
				if events.size() > 0:
					default_settings.input[action] = _input_event_to_dict(events[0])
					print("↳ Using InputMap fallback for " + action)

func load_settings():
	"""Load settings from JSON file"""
	print("Loading settings from: " + CONFIG_FILE_PATH)
	
	if FileAccess.file_exists(CONFIG_FILE_PATH):
		var file = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			
			if parse_result == OK:
				var loaded_data = json.data
				if loaded_data is Dictionary:
					# Merge loaded settings with defaults (this handles new settings added in updates)
					current_settings = _merge_settings(default_settings, loaded_data)
					print("✓ Settings loaded successfully")
					_apply_loaded_settings()
					settings_loaded.emit()
					return
				else:
					print("✗ Invalid JSON structure in settings file")
			else:
				print("✗ JSON parse error: " + json.error_string)
		else:
			print("✗ Could not open settings file")
	else:
		print("No settings file found, using defaults")
	
	# Use defaults if loading failed
	current_settings = default_settings.duplicate(true)
	save_settings()  # Create the file with defaults
	settings_loaded.emit()

func save_settings():
	"""Save current settings to JSON file"""
	print("Saving settings to: " + CONFIG_FILE_PATH)
	
	var file = FileAccess.open(CONFIG_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(current_settings, "\t")
		file.store_string(json_string)
		file.close()
		print("✓ Settings saved successfully")
		settings_saved.emit()
		return true
	else:
		print("✗ Could not save settings file")
		return false

func _merge_settings(defaults: Dictionary, loaded: Dictionary) -> Dictionary:
	"""Recursively merge loaded settings with defaults to handle new settings"""
	var result = defaults.duplicate(true)
	
	for key in loaded.keys():
		if key in result:
			if result[key] is Dictionary and loaded[key] is Dictionary:
				result[key] = _merge_settings(result[key], loaded[key])
			else:
				result[key] = loaded[key]
		else:
			# New setting not in defaults, add it anyway
			result[key] = loaded[key]
	
	return result

func _apply_loaded_settings():
	"""Apply loaded settings to the game systems"""
	print("Applying loaded settings...")
	
	# Apply input settings
	print("- Applying input settings...")
	_apply_input_settings()
	
	# Apply graphics settings
	print("- Applying graphics settings...")
	_apply_graphics_settings()
	
	# Apply audio settings
	print("- Applying audio settings...")
	_apply_audio_settings()
	
	print("✅ All settings applied")

func _apply_input_settings():
	"""Apply input settings to InputMap"""
	if not current_settings.has("input"):
		return
		
	for action in current_settings.input.keys():
		var input_data = current_settings.input[action]
		if input_data and InputMap.has_action(action):
			var input_event = _dict_to_input_event(input_data)
			if input_event:
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, input_event)

func _apply_graphics_settings():
	"""Apply graphics settings"""
	if not current_settings.has("graphics"):
		return
	
	var graphics = current_settings.graphics
	
	# Window mode
	var window_mode = graphics.get("window_mode", 0)
	match window_mode:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	# Resolution
	var width = graphics.get("resolution_width", 1920)
	var height = graphics.get("resolution_height", 1080)
	if window_mode == 0:  # Only set size for windowed mode
		DisplayServer.window_set_size(Vector2i(width, height))
	
	# VSync
	var vsync = graphics.get("vsync_enabled", true)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	
	print("Applied graphics settings: window_mode=" + str(window_mode) + ", resolution=" + str(width) + "x" + str(height) + ", vsync=" + str(vsync))

func _apply_audio_settings():
	"""Apply audio settings"""
	if not current_settings.has("audio"):
		return
	
	var audio = current_settings.audio
	
	# Set audio bus volumes (convert 0-1 range to decibels)
	var master_bus = AudioServer.get_bus_index("Master")
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	
	# Apply master volume
	var master_volume = audio.get("master_volume", 1.0)
	if master_bus >= 0:
		var master_db = linear_to_db(master_volume) if master_volume > 0 else -80.0
		AudioServer.set_bus_volume_db(master_bus, master_db)
		print("Applied master volume: " + str(master_volume) + " (" + str(master_db) + " dB)")
	
	# Apply music volume
	var music_volume = audio.get("music_volume", 0.8)
	if music_bus >= 0:
		var music_db = linear_to_db(music_volume) if music_volume > 0 else -80.0
		AudioServer.set_bus_volume_db(music_bus, music_db)
		print("Applied music volume: " + str(music_volume) + " (" + str(music_db) + " dB)")
	
	# Apply SFX volume
	var sfx_volume = audio.get("sfx_volume", 1.0)
	if sfx_bus >= 0:
		var sfx_db = linear_to_db(sfx_volume) if sfx_volume > 0 else -80.0
		AudioServer.set_bus_volume_db(sfx_bus, sfx_db)
		print("Applied SFX volume: " + str(sfx_volume) + " (" + str(sfx_db) + " dB)")

# === SETTING GETTERS AND SETTERS ===

func get_setting(category: String, key: String, default_value = null):
	"""Get a specific setting value"""
	if category in current_settings and key in current_settings[category]:
		return current_settings[category][key]
	return default_value

func set_setting(category: String, key: String, value):
	"""Set a specific setting value and save immediately"""
	if not category in current_settings:
		current_settings[category] = {}
	
	var old_value = current_settings[category].get(key)
	current_settings[category][key] = value
	
	if old_value != value:
		setting_changed.emit(category, key, value)
		save_settings()
		print("Setting changed: " + category + "." + key + " = " + str(value))

func reset_category_to_defaults(category: String):
	"""Reset an entire category to default values"""
	if category in default_settings:
		current_settings[category] = default_settings[category].duplicate(true)
		save_settings()
		
		# Re-apply settings for this category
		match category:
			"input":
				_apply_input_settings()
			"graphics":
				_apply_graphics_settings()
			"audio":
				_apply_audio_settings()
		
		print("Reset category '" + category + "' to defaults")
		return true
	return false

func reset_all_to_defaults():
	"""Reset all settings to defaults"""
	current_settings = default_settings.duplicate(true)
	save_settings()
	_apply_loaded_settings()
	print("All settings reset to defaults")

# === INPUT EVENT CONVERSION HELPERS ===

func _input_event_to_dict(event: InputEvent) -> Dictionary:
	"""Convert InputEvent to Dictionary for JSON storage"""
	var dict = {
		"type": "",
		"data": {}
	}
	
	if event is InputEventKey:
		dict.type = "key"
		dict.data = {
			"keycode": event.keycode,
			"physical_keycode": event.physical_keycode,
			"key_label": event.key_label,
			"unicode": event.unicode
		}
	elif event is InputEventMouseButton:
		dict.type = "mouse_button"
		dict.data = {
			"button_index": event.button_index
		}
	elif event is InputEventJoypadButton:
		dict.type = "joypad_button"
		dict.data = {
			"button_index": event.button_index,
			"device": event.device
		}
	elif event is InputEventJoypadMotion:
		dict.type = "joypad_motion"
		dict.data = {
			"axis": event.axis,
			"axis_value": event.axis_value,
			"device": event.device
		}
	
	return dict

func _dict_to_input_event(dict: Dictionary) -> InputEvent:
	"""Convert Dictionary back to InputEvent"""
	if not dict.has("type") or not dict.has("data"):
		return null
	
	var event: InputEvent = null
	
	match dict.type:
		"key":
			event = InputEventKey.new()
			event.keycode = dict.data.get("keycode", 0)
			event.physical_keycode = dict.data.get("physical_keycode", 0)
			event.key_label = dict.data.get("key_label", 0)
			event.unicode = dict.data.get("unicode", 0)
		"mouse_button":
			event = InputEventMouseButton.new()
			event.button_index = dict.data.get("button_index", 1)
		"joypad_button":
			event = InputEventJoypadButton.new()
			event.button_index = dict.data.get("button_index", 0)
			event.device = dict.data.get("device", -1)
		"joypad_motion":
			event = InputEventJoypadMotion.new()
			event.axis = dict.data.get("axis", 0)
			event.axis_value = dict.data.get("axis_value", 1.0)
			event.device = dict.data.get("device", -1)
	
	return event

# === CONVENIENCE FUNCTIONS ===

func get_input_setting(action: String) -> InputEvent:
	"""Get input setting as InputEvent"""
	var input_data = get_setting("input", action)
	if input_data:
		return _dict_to_input_event(input_data)
	return null

func set_input_setting(action: String, event: InputEvent):
	"""Set input setting from InputEvent"""
	var input_data = _input_event_to_dict(event)
	set_setting("input", action, input_data)
	
	# Apply immediately to InputMap
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

func get_default_input_setting(action: String) -> InputEvent:
	"""Get default input setting for an action"""
	if action in default_settings.input and default_settings.input[action]:
		return _dict_to_input_event(default_settings.input[action])
	return null

# === AUDIO HELPER FUNCTIONS ===

func set_master_volume_percent(percent: float):
	"""Set master volume from 0-100 percent"""
	var volume = percent / 100.0
	set_setting("audio", "master_volume", volume)
	# Apply immediately
	var master_bus = AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		var db = linear_to_db(volume) if volume > 0 else -80.0
		AudioServer.set_bus_volume_db(master_bus, db)

func get_master_volume_percent() -> float:
	"""Get master volume as 0-100 percent"""
	var volume = get_setting("audio", "master_volume", 1.0)
	return volume * 100.0

func set_music_volume_percent(percent: float):
	"""Set music volume from 0-100 percent"""
	var volume = percent / 100.0
	set_setting("audio", "music_volume", volume)
	# Apply immediately
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		var db = linear_to_db(volume) if volume > 0 else -80.0
		AudioServer.set_bus_volume_db(music_bus, db)

func get_music_volume_percent() -> float:
	"""Get music volume as 0-100 percent"""
	var volume = get_setting("audio", "music_volume", 0.8)
	return volume * 100.0

func set_sfx_volume_percent(percent: float):
	"""Set SFX volume from 0-100 percent"""
	var volume = percent / 100.0
	set_setting("audio", "sfx_volume", volume)
	# Apply immediately
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		var db = linear_to_db(volume) if volume > 0 else -80.0
		AudioServer.set_bus_volume_db(sfx_bus, db)

func get_sfx_volume_percent() -> float:
	"""Get SFX volume as 0-100 percent"""
	var volume = get_setting("audio", "sfx_volume", 1.0)
	return volume * 100.0

# === GRAPHICS HELPER FUNCTIONS ===

func set_window_mode(mode: int):
	"""Set window mode (0=Windowed, 1=Fullscreen, 2=Borderless)"""
	set_setting("graphics", "window_mode", mode)
	# Apply immediately
	match mode:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func get_window_mode() -> int:
	"""Get current window mode"""
	return get_setting("graphics", "window_mode", 0)

# === DEBUG FUNCTIONS ===

func print_all_settings():
	"""Print all current settings to console"""
	print("=== CURRENT SETTINGS ===")
	print(JSON.stringify(current_settings, "\t"))
	print("========================")

func export_settings_to_file(file_path: String = "user://settings_backup.json"):
	"""Export settings to a backup file"""
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_settings, "\t"))
		file.close()
		print("Settings exported to: " + file_path)
		return true
	return false
