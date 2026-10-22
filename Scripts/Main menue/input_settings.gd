extends Control

## Tastenbelegung. Speichert über den ConfigManager.
## Doppelt belegte Tasten werden rot markiert.

const ACTION_LABEL_PATH = "MarginContainer/HBoxContainer/Lable Action"
const INPUT_LABEL_PATH = "MarginContainer/HBoxContainer/Lable Input"
const RESET_BUTTON_PATH = "MarginContainer/HBoxContainer/ResetButton"

@onready var input_button_scene = preload("res://Szene/main menue/Options/utils/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

## Aktion -> Anzeigename. Neue Aktionen hier eintragen (und in den Projekteinstellungen anlegen).
var input_actions = {
	"move_up": "Move Up",
	"move_down": "Move Down",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"jump": "Jump",
	"interact": "Interact",
	"pause": "Pause",
}

var action_buttons = {}  # Aktion -> Button, für die Doppelbelegungs-Prüfung

func _ready() -> void:
	if ConfigManager.current_settings.is_empty():
		ConfigManager.settings_loaded.connect(_create_action_list)
	else:
		_create_action_list()

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible and not action_buttons.is_empty():
		_check_for_duplicate_mappings()

## Baut für jede Aktion eine Zeile mit Name, Taste und Reset-Knopf.
func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()
	action_buttons.clear()

	# Einen Frame warten, bis die alten Zeilen weg sind
	await get_tree().process_frame

	for action in input_actions:
		if not InputMap.has_action(action):
			push_warning("Aktion '%s' fehlt in der InputMap" % action)
			continue

		var button = input_button_scene.instantiate()
		var action_label = button.get_node_or_null(ACTION_LABEL_PATH)
		var reset_button = button.get_node_or_null(RESET_BUTTON_PATH)
		if not action_label or not _get_input_label(button) or not reset_button:
			push_warning("input_button.tscn hat nicht die erwarteten Kind-Nodes")
			continue

		action_label.text = input_actions[action]
		_show_current_binding(action, button)

		button.pressed.connect(_on_input_button_pressed.bind(action, button))
		reset_button.pressed.connect(_on_individual_reset_pressed.bind(action))
		reset_button.mouse_filter = Control.MOUSE_FILTER_STOP  # Reset soll nicht den Haupt-Button auslösen

		action_buttons[action] = button
		action_list.add_child(button)

	_check_for_duplicate_mappings()

func _get_input_label(button: Node) -> Label:
	return button.get_node_or_null(INPUT_LABEL_PATH)

## Zeigt die aktuell belegte Taste einer Aktion auf ihrem Button an.
func _show_current_binding(action: String, button: Node):
	var input_label = _get_input_label(button)
	if not input_label:
		return
	var events = InputMap.action_get_events(action)
	input_label.text = _get_event_text(events[0]) if events.size() > 0 else "Not Set"
	input_label.modulate = Color.WHITE

## Lesbarer Name einer Taste
func _get_event_text(event: InputEvent) -> String:
	if event is InputEventKey:
		return OS.get_keycode_string(event.physical_keycode) if event.physical_keycode != 0 else OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: return "Left Mouse"
			MOUSE_BUTTON_RIGHT: return "Right Mouse"
			MOUSE_BUTTON_MIDDLE: return "Middle Mouse"
			MOUSE_BUTTON_WHEEL_UP: return "Wheel Up"
			MOUSE_BUTTON_WHEEL_DOWN: return "Wheel Down"
			_: return "Mouse Button " + str(event.button_index)
	elif event is InputEventJoypadButton:
		return "Gamepad Button " + str(event.button_index)
	elif event is InputEventJoypadMotion:
		return "Gamepad Axis " + str(event.axis)
	return event.as_text()

## Eindeutiger Schlüssel pro Taste, um Doppelbelegungen zu finden
func _get_event_key(event: InputEvent) -> String:
	if event is InputEventKey:
		var keycode = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		return "key_" + str(keycode)
	elif event is InputEventMouseButton:
		return "mouse_" + str(event.button_index)
	elif event is InputEventJoypadButton:
		return "joypad_btn_" + str(event.button_index)
	elif event is InputEventJoypadMotion:
		return "joypad_axis_" + str(event.axis) + "_" + str(sign(event.axis_value))
	return ""

func _on_input_button_pressed(action: String, button: Button):
	if is_remapping:
		return
	is_remapping = true
	action_to_remap = action
	remapping_button = button

	var input_label = _get_input_label(button)
	if input_label:
		input_label.text = "Press any key..."
		input_label.modulate = Color.YELLOW

func _on_individual_reset_pressed(action: String):
	var default_event = ConfigManager.get_default_input_setting(action)
	if not default_event:
		push_warning("Keine Standardbelegung für '%s'" % action)
		return

	ConfigManager.set_input_setting(action, default_event)  # speichert automatisch
	if action in action_buttons:
		_show_current_binding(action, action_buttons[action])
	_check_for_duplicate_mappings()

## Markiert alle Aktionen rot, die sich eine Taste teilen.
func _check_for_duplicate_mappings():
	var input_to_actions = {}

	for action in action_buttons:
		var input_label = _get_input_label(action_buttons[action])
		if input_label:
			input_label.modulate = Color.WHITE

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event_key = _get_event_key(events[0])
			if event_key != "":
				input_to_actions.get_or_add(event_key, []).append(action)

	for event_key in input_to_actions:
		if input_to_actions[event_key].size() > 1:
			for action in input_to_actions[event_key]:
				var input_label = _get_input_label(action_buttons[action])
				if input_label:
					input_label.modulate = Color.RED

func _input(event: InputEvent):
	if not is_remapping:
		return
	if not (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton):
		return
	if not event.pressed:
		return

	# Escape bricht ab und kann nicht belegt werden
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		_cancel_remap()
		return

	# Doppelbelegung ist erlaubt, wird aber danach rot markiert
	ConfigManager.set_input_setting(action_to_remap, event)  # speichert automatisch
	_show_current_binding(action_to_remap, remapping_button)

	is_remapping = false
	action_to_remap = null
	remapping_button = null

	get_viewport().set_input_as_handled()
	_check_for_duplicate_mappings()

func _cancel_remap():
	if remapping_button:
		_show_current_binding(action_to_remap, remapping_button)

	is_remapping = false
	action_to_remap = null
	remapping_button = null
	_check_for_duplicate_mappings()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")

func _on_reset_pressed() -> void:
	ConfigManager.reset_category_to_defaults("input")
	_create_action_list()
