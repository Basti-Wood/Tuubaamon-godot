extends Control
# Updated input_settings.gd - Now uses ConfigManager for persistent settings

@onready var input_button_scene = preload("res://Szene/main menue/Options/utils/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"move_up": "Move Up",
	"move_down": "Move Down", 
	"move_left": "Move Left",
	"move_right": "Move Right",
	"jump": "Jump",
	"interact": "Interact",
	"pause": "Pause",
	# Add more actions as needed
}

var action_buttons = {} # Store references to all buttons for duplicate checking

func _ready() -> void:
	print("=== Input Settings Ready ===")
	# Wait for ConfigManager to be ready
	if ConfigManager.current_settings.is_empty():
		ConfigManager.settings_loaded.connect(_on_config_loaded)
	else:
		_on_config_loaded()

func _on_config_loaded():
	"""Called when ConfigManager has loaded settings"""
	print("ConfigManager loaded, creating input UI...")
	_create_action_list()
	# Check for duplicates after everything is ready (deferred)
	call_deferred("_check_for_duplicate_mappings_delayed")

func _notification(what):
	"""Handle scene visibility changes"""
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible and not action_buttons.is_empty():
			# Scene became visible, check for duplicates again
			call_deferred("_check_for_duplicate_mappings_delayed")

func _create_action_list():
	"""Create the UI buttons for each input action"""
	print("Creating action list...")
	
	# Clear existing buttons
	for items in action_list.get_children():
		items.queue_free()
	
	action_buttons.clear()
	
	# Wait one frame for cleanup to complete
	await get_tree().process_frame
	
	# Create buttons for each action
	for action in input_actions:
		# Skip if action doesn't exist in InputMap
		if not InputMap.has_action(action):
			print("Warning: Action '" + action + "' not found in InputMap")
			continue
			
		var button = input_button_scene.instantiate()
		# Using correct node paths with error handling
		var action_label = null
		var input_label = null
		var reset_button = null
		
		if button.has_node("MarginContainer/HBoxContainer/Lable Action"):
			action_label = button.get_node("MarginContainer/HBoxContainer/Lable Action")
		if button.has_node("MarginContainer/HBoxContainer/Lable Input"):
			input_label = button.get_node("MarginContainer/HBoxContainer/Lable Input")
		if button.has_node("MarginContainer/HBoxContainer/ResetButton"):
			reset_button = button.get_node("MarginContainer/HBoxContainer/ResetButton")
		
		if not action_label or not input_label or not reset_button:
			print("Warning: Could not find required child nodes in input button scene")
			print("Available children:")
			for child in button.get_children():
				print("  " + child.name)
			continue
		
		# Set up action label
		action_label.text = input_actions[action]
		
		# Set up input label from current InputMap
		if input_label:
			var events = InputMap.action_get_events(action)
			if events.size() > 0:
				input_label.text = _get_event_text(events[0])
			else:
				input_label.text = "Not Set"
		
		# Connect the main button signal for remapping
		button.pressed.connect(_on_input_button_pressed.bind(action, button))
		button.set_meta("action", action)
		
		# Connect the individual reset button signal
		reset_button.pressed.connect(_on_individual_reset_pressed.bind(action))
		# Ensure reset button doesn't trigger the main button
		reset_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Store button reference for duplicate checking
		action_buttons[action] = button
		
		action_list.add_child(button)
	
	print("Created " + str(action_buttons.size()) + " input buttons")
	
	# After all buttons are created, check for duplicates
	call_deferred("_check_for_duplicate_mappings_delayed")

func _get_event_text(event: InputEvent) -> String:
	"""Convert input event to human readable text"""
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
	else:
		return event.as_text()

func _on_input_button_pressed(action: String, button: Button):
	"""Handle main button press to start remapping"""
	if not is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		
		# Update button text to show it's waiting for input
		var input_label = null
		if button.has_node("MarginContainer/HBoxContainer/Lable Input"):
			input_label = button.get_node("MarginContainer/HBoxContainer/Lable Input")
		if input_label:
			input_label.text = "Press any key..."
			input_label.modulate = Color.YELLOW

func _on_individual_reset_pressed(action: String):
	"""Reset a specific action to its default binding using ConfigManager"""
	print("=== Individual Reset: " + action + " ===")
	
	# Get the default binding from ConfigManager
	var default_event = ConfigManager.get_default_input_setting(action)
	if default_event:
		print("Found default binding for " + action + ": " + _get_event_text(default_event))
		
		# Set the binding using ConfigManager (this saves automatically)
		ConfigManager.set_input_setting(action, default_event)
		
		# Update the button display
		if action in action_buttons:
			var button = action_buttons[action]
			var input_label = null
			if button.has_node("MarginContainer/HBoxContainer/Lable Input"):
				input_label = button.get_node("MarginContainer/HBoxContainer/Lable Input")
			if input_label:
				input_label.text = _get_event_text(default_event)
				input_label.modulate = Color.WHITE
				print("Updated button display for " + action)
			else:
				print("Could not find input label for " + action)
		else:
			print("Action " + action + " not found in action_buttons")
		
		# Check for duplicates after reset
		_check_for_duplicate_mappings()
		
		print("✓ Action '" + action + "' reset to default: " + _get_event_text(default_event))
	else:
		print("✗ No default binding found for action: " + action)
	print("=== Individual Reset Complete ===")

func _check_for_duplicate_mappings():
	"""Check for duplicate input mappings and highlight them in red"""
	print("Checking for duplicate mappings...")
	# Build a dictionary of which actions use which inputs
	var input_to_actions = {}
	
	# Reset all button colors first
	for action in action_buttons:
		var button = action_buttons[action]
		var input_label = null
		if button.has_node("MarginContainer/HBoxContainer/Lable Input"):
			input_label = button.get_node("MarginContainer/HBoxContainer/Lable Input")
		else:
			print("Node path not found for action: " + action)
			continue
			
		if input_label:
			input_label.modulate = Color.WHITE
			#print("Reset color for action: " + action + ", label text: " + input_label.text)
		else:
			print("Could not find input label for action: " + action)
	
	# Build mapping of inputs to actions
	for action in input_actions:
		if not InputMap.has_action(action):
			continue
			
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event_key = _get_event_key(events[0])
			if event_key != "":
				if not event_key in input_to_actions:
					input_to_actions[event_key] = []
				input_to_actions[event_key].append(action)
	
	# Highlight duplicates in red
	var duplicate_count = 0
	for event_key in input_to_actions:
		if input_to_actions[event_key].size() > 1:
			duplicate_count += 1
			print("Duplicate mapping found for '" + event_key + "': " + str(input_to_actions[event_key]))
			
			# Multiple actions use the same input - highlight them in red
			for action in input_to_actions[event_key]:
				if action in action_buttons:
					var button = action_buttons[action]
					var input_label = null
					if button.has_node("MarginContainer/HBoxContainer/Lable Input"):
						input_label = button.get_node("MarginContainer/HBoxContainer/Lable Input")
					else:
						print("Node path not found for duplicate action: " + action)
						continue
						
					if input_label:
						input_label.modulate = Color.RED
						print("Set RED color for action: " + action + ", label text: " + input_label.text)
					else:
						print("Could not find input label for duplicate action: " + action)
	
	if duplicate_count == 0:
		print("No duplicate mappings found")

func _check_for_duplicate_mappings_delayed():
	"""Deferred duplicate checking to ensure UI is fully ready"""
	print("=== Running Deferred Duplicate Check ===")
	# Wait a bit more to ensure everything is fully loaded
	await get_tree().process_frame
	await get_tree().process_frame
	print("UI should be ready now, checking for duplicates...")
	_check_for_duplicate_mappings()
	print("=== Deferred Duplicate Check Complete ===")

func _get_event_key(event: InputEvent) -> String:
	"""Create a unique string key for each input event for comparison"""
	if event is InputEventKey:
		var keycode = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		return "key_" + str(keycode)
	elif event is InputEventMouseButton:
		return "mouse_" + str(event.button_index)
	elif event is InputEventJoypadButton:
		return "joypad_btn_" + str(event.button_index)
	elif event is InputEventJoypadMotion:
		return "joypad_axis_" + str(event.axis) + "_" + str(sign(event.axis_value))
	else:
		return ""

func _input(event: InputEvent):
	"""Handle input events during remapping"""
	if is_remapping:
		# Accept key, mouse button, or gamepad input
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
			if event.pressed:
				# Don't allow escape to be remapped (keep it for canceling)
				if event is InputEventKey and event.keycode == KEY_ESCAPE:
					_cancel_remap()
					return
				
				# Store the action name before we clear it
				var current_action = action_to_remap
				
				# Check if this input is already used by another action
				var event_key = _get_event_key(event)
				var conflicting_actions = []
				
				for action in input_actions:
					if action == current_action:
						continue # Skip the action we're currently remapping
					if not InputMap.has_action(action):
						continue
					
					var existing_events = InputMap.action_get_events(action)
					for existing_event in existing_events:
						if _get_event_key(existing_event) == event_key:
							conflicting_actions.append(action)
				
				# Warn about conflicts but allow the mapping
				if conflicting_actions.size() > 0:
					print("Warning: Input '" + _get_event_text(event) + "' is already used by: " + str(conflicting_actions))
				
				# Use ConfigManager to set the new input (this saves automatically)
				ConfigManager.set_input_setting(current_action, event)
				
				# Update the button label
				var input_label = null
				if remapping_button.has_node("MarginContainer/HBoxContainer/Lable Input"):
					input_label = remapping_button.get_node("MarginContainer/HBoxContainer/Lable Input")
				if input_label:
					input_label.text = _get_event_text(event)
					input_label.modulate = Color.WHITE
				
				# Reset remapping state
				is_remapping = false
				action_to_remap = null
				remapping_button = null
				
				# Stop the input from propagating
				get_viewport().set_input_as_handled()
				
				# Check for duplicate mappings
				_check_for_duplicate_mappings()
				
				print("Mapped '" + _get_event_text(event) + "' to action '" + current_action + "'")

func _cancel_remap():
	"""Cancel the current remapping operation"""
	print("Remapping cancelled")
	
	if remapping_button:
		var input_label = null
		if remapping_button.has_node("MarginContainer/HBoxContainer/Lable Input"):
			input_label = remapping_button.get_node("MarginContainer/HBoxContainer/Lable Input")
		if input_label:
			var events = InputMap.action_get_events(action_to_remap)
			if events.size() > 0:
				input_label.text = _get_event_text(events[0])
			else:
				input_label.text = "Not Set"
			input_label.modulate = Color.WHITE
	
	is_remapping = false
	action_to_remap = null
	remapping_button = null
	
	# Re-check for duplicates
	_check_for_duplicate_mappings()

func _on_exit_pressed() -> void:
	"""Handle exit button press"""
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")

func _on_reset_pressed() -> void:
	"""Reset all inputs to default values using ConfigManager"""
	print("Resetting all inputs to defaults using ConfigManager")
	
	# Use ConfigManager to reset all input settings
	ConfigManager.reset_category_to_defaults("input")
	
	# Recreate the action list to update all displays
	_create_action_list()
	
	print("All input settings reset to defaults")
