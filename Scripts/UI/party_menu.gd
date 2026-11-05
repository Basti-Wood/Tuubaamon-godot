extends PanelContainer

## Team-Menü: zeigt GameState.party. Zwei Monster nacheinander doppelklicken = Plätze tauschen.

var _list := ItemList.new()
var _first := -1

func _ready() -> void:
	custom_minimum_size = Vector2(400, 300)
	var box := VBoxContainer.new()
	add_child(box)
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.item_activated.connect(_on_activated)
	box.add_child(_list)
	var back := Button.new()
	back.text = "Zurück"
	back.pressed.connect(queue_free)
	box.add_child(back)
	_refresh()

func _refresh() -> void:
	_list.clear()
	for monster in GameState.party:
		_list.add_item("%s  Lv %d  KP %d/%d" % [monster.get_display_name(), monster.level, monster.current_hp, monster.get_max_hp()])

func _on_activated(index: int) -> void:
	if _first == -1:
		_first = index
		return
	var party := GameState.party
	var temp = party[index]
	party[index] = party[_first]
	party[_first] = temp
	_first = -1
	_refresh()
