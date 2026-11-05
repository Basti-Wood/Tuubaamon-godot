extends CanvasLayer

## Textbox für NPCs, Schilder und Story. Autoload "DialogueBox".
## Benutzen:  await DialogueBox.show_lines(["Hallo!", "Wie geht's?"], "Tuubaa")
## "interact": Zeile sofort ganz zeigen, nochmal drücken = nächste Zeile.

signal finished

const CHARS_PER_SEC := 40.0

var is_open := false
var _lines: Array = []
var _index := 0
var _tween: Tween
var _panel := PanelContainer.new()
var _name := Label.new()
var _text := Label.new()

func _ready() -> void:
	layer = 10
	_panel.theme = load("res://Assets/UI/main_theme.tres")
	_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top = -140
	var box := VBoxContainer.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_name)
	box.add_child(_text)
	_panel.add_child(box)
	add_child(_panel)
	_panel.hide()

func show_lines(lines: Array, speaker := "") -> void:
	if lines.is_empty():
		return
	_lines = lines
	_index = 0
	_name.text = speaker
	_name.visible = speaker != ""
	is_open = true
	_panel.show()
	_show_line()
	await finished

func _show_line() -> void:
	_text.text = _lines[_index]
	_text.visible_ratio = 0.0
	_tween = create_tween()
	_tween.tween_property(_text, "visible_ratio", 1.0, _text.text.length() / CHARS_PER_SEC)

func _unhandled_input(event: InputEvent) -> void:
	if not is_open or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	if _tween.is_running():
		_tween.kill()
		_text.visible_ratio = 1.0
		return
	_index += 1
	if _index < _lines.size():
		_show_line()
	else:
		is_open = false
		_panel.hide()
		finished.emit()
