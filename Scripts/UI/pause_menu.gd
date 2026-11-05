extends CanvasLayer

## Pausemenü in der Overworld. In der Map-Szene einen CanvasLayer anlegen und dieses Skript draufziehen.
## Die Knöpfe baut das Skript selbst, eine eigene Szene ist nicht nötig. Öffnen/Schließen mit "pause" (Esc).

const InventoryMenu := preload("res://Scripts/UI/inventory_menu.gd")
const PartyMenu := preload("res://Scripts/UI/party_menu.gd")
const SAVE_SLOT := 1
const MAIN_MENU := "res://Szene/main menue/main_menue.tscn"

var _center := CenterContainer.new()
var _buttons := VBoxContainer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # läuft weiter, obwohl das Spiel pausiert ist
	_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_center)
	_center.add_child(_buttons)
	_add_button("Weiter", close)
	_add_button("Team", func(): _open_submenu(PartyMenu.new()))
	_add_button("Inventar", func(): _open_submenu(InventoryMenu.new()))
	_add_button("Speichern", func(): SaveManager.save_game(SAVE_SLOT))
	_add_button("Hauptmenü", _on_quit_pressed)
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()

func open() -> void:
	get_tree().paused = true
	_buttons.show()
	show()

func close() -> void:
	for child in _center.get_children():
		if child != _buttons:
			child.queue_free()
	get_tree().paused = false
	hide()

func _add_button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	_buttons.add_child(button)

func _open_submenu(menu: Control) -> void:
	_buttons.hide()
	menu.tree_exited.connect(_buttons.show)   # Untermenü zu -> Knöpfe wieder zeigen
	_center.add_child(menu)

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)
