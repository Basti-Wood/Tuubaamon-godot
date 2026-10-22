extends Node

## Zentrale Verwaltung der Einstellungen (Autoload "ConfigManager").
## Speichert alles als JSON unter user://config/settings.json.

signal settings_loaded
signal settings_saved
signal setting_changed(category: String, key: String, value)

const CONFIG_DIR_PATH = "user://config/"
const CONFIG_FILE_PATH = "user://config/settings.json"

## Reihenfolge passt zur Auswahl im Grafik-Menü
enum WindowMode { WINDOWED, FULLSCREEN, BORDERLESS }

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
		"window_mode": WindowMode.WINDOWED,
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

## Aktuelle Einstellungen (aus Datei geladen oder Standardwerte)
var current_settings = {}

func _ready():
	DirAccess.make_dir_recursive_absolute(CONFIG_DIR_PATH)
	_load_project_input_defaults()
	load_settings()

## Übernimmt die Tastenbelegung aus den Projekteinstellungen als Standardwerte.
func _load_project_input_defaults():
	for action in default_settings.input.keys():
		if not InputMap.has_action(action):
			continue
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			default_settings.input[action] = _input_event_to_dict(events[0])

# =========================
# LADEN / SPEICHERN
# =========================

func load_settings():
	current_settings = default_settings.duplicate(true)

	if FileAccess.file_exists(CONFIG_FILE_PATH):
		var json = JSON.new()
		if json.parse(FileAccess.get_file_as_string(CONFIG_FILE_PATH)) == OK and json.data is Dictionary:
			# Mit Standardwerten zusammenführen, damit neue Einstellungen nach Updates da sind
			current_settings = _merge_settings(default_settings, json.data)
		else:
			push_warning("ConfigManager: settings.json ist kaputt, nutze Standardwerte.")
	else:
		save_settings()

	_apply_all_settings()
	settings_loaded.emit()

func save_settings() -> bool:
	var file = FileAccess.open(CONFIG_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("ConfigManager: konnte %s nicht schreiben." % CONFIG_FILE_PATH)
		return false
	file.store_string(JSON.stringify(current_settings, "\t"))
	file.close()
	settings_saved.emit()
	return true

## Führt geladene Einstellungen rekursiv mit den Standardwerten zusammen.
func _merge_settings(defaults: Dictionary, loaded: Dictionary) -> Dictionary:
	var result = defaults.duplicate(true)
	for key in loaded.keys():
		if key in result and result[key] is Dictionary and loaded[key] is Dictionary:
			result[key] = _merge_settings(result[key], loaded[key])
		else:
			result[key] = loaded[key]
	return result

# =========================
# ANWENDEN
# =========================

func _apply_all_settings():
	_apply_input_settings()
	_apply_graphics_settings()
	_apply_audio_settings()

func _apply_input_settings():
	var input: Dictionary = current_settings.get("input", {})
	for action in input.keys():
		var input_data = input[action]
		if input_data and InputMap.has_action(action):
			var input_event = _dict_to_input_event(input_data)
			if input_event:
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, input_event)

func _apply_graphics_settings():
	var graphics: Dictionary = current_settings.get("graphics", {})
	# JSON liefert Zahlen als float, darum int()
	var window_mode := int(graphics.get("window_mode", WindowMode.WINDOWED))
	_apply_window_mode(window_mode)

	if window_mode == WindowMode.WINDOWED:
		var width := int(graphics.get("resolution_width", 1920))
		var height := int(graphics.get("resolution_height", 1080))
		DisplayServer.window_set_size(Vector2i(width, height))

	var vsync = graphics.get("vsync_enabled", true)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)

func _apply_audio_settings():
	var audio: Dictionary = current_settings.get("audio", {})
	_apply_bus_volume("Master", audio.get("master_volume", 1.0))
	_apply_bus_volume("Music", audio.get("music_volume", 0.8))
	_apply_bus_volume("SFX", audio.get("sfx_volume", 1.0))

func _apply_window_mode(mode: int):
	match mode:
		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

## Setzt die Lautstärke eines Audio-Busses (volume 0.0 bis 1.0).
func _apply_bus_volume(bus_name: String, volume: float):
	var bus = AudioServer.get_bus_index(bus_name)
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(volume) if volume > 0 else -80.0)

# =========================
# GETTER / SETTER
# =========================

func get_setting(category: String, key: String, default_value = null):
	if category in current_settings and key in current_settings[category]:
		return current_settings[category][key]
	return default_value

## Setzt einen Wert und speichert sofort.
func set_setting(category: String, key: String, value):
	if not category in current_settings:
		current_settings[category] = {}

	var old_value = current_settings[category].get(key)
	current_settings[category][key] = value

	if old_value != value:
		setting_changed.emit(category, key, value)
		save_settings()

func reset_category_to_defaults(category: String) -> bool:
	if not category in default_settings:
		return false

	current_settings[category] = default_settings[category].duplicate(true)
	save_settings()
	match category:
		"input":
			_apply_input_settings()
		"graphics":
			_apply_graphics_settings()
		"audio":
			_apply_audio_settings()
	return true

func reset_all_to_defaults():
	current_settings = default_settings.duplicate(true)
	save_settings()
	_apply_all_settings()

# =========================
# INPUT
# =========================

func get_input_setting(action: String) -> InputEvent:
	var input_data = get_setting("input", action)
	return _dict_to_input_event(input_data) if input_data else null

func set_input_setting(action: String, event: InputEvent):
	set_setting("input", action, _input_event_to_dict(event))
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

func get_default_input_setting(action: String) -> InputEvent:
	if action in default_settings.input and default_settings.input[action]:
		return _dict_to_input_event(default_settings.input[action])
	return null

## InputEvent -> Dictionary (für JSON)
func _input_event_to_dict(event: InputEvent) -> Dictionary:
	var dict = {"type": "", "data": {}}

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
		dict.data = {"button_index": event.button_index}
	elif event is InputEventJoypadButton:
		dict.type = "joypad_button"
		dict.data = {"button_index": event.button_index, "device": event.device}
	elif event is InputEventJoypadMotion:
		dict.type = "joypad_motion"
		dict.data = {"axis": event.axis, "axis_value": event.axis_value, "device": event.device}

	return dict

## Dictionary -> InputEvent
func _dict_to_input_event(dict: Dictionary) -> InputEvent:
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

# =========================
# AUDIO (Werte in Prozent 0-100)
# =========================

func set_master_volume_percent(percent: float):
	set_setting("audio", "master_volume", percent / 100.0)
	_apply_bus_volume("Master", percent / 100.0)

func get_master_volume_percent() -> float:
	return get_setting("audio", "master_volume", 1.0) * 100.0

func set_music_volume_percent(percent: float):
	set_setting("audio", "music_volume", percent / 100.0)
	_apply_bus_volume("Music", percent / 100.0)

func get_music_volume_percent() -> float:
	return get_setting("audio", "music_volume", 0.8) * 100.0

func set_sfx_volume_percent(percent: float):
	set_setting("audio", "sfx_volume", percent / 100.0)
	_apply_bus_volume("SFX", percent / 100.0)

func get_sfx_volume_percent() -> float:
	return get_setting("audio", "sfx_volume", 1.0) * 100.0

# =========================
# GRAFIK
# =========================

func set_window_mode(mode: int):
	set_setting("graphics", "window_mode", mode)
	_apply_window_mode(mode)

func get_window_mode() -> int:
	return int(get_setting("graphics", "window_mode", WindowMode.WINDOWED))
