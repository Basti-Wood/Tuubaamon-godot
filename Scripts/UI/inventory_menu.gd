extends PanelContainer

## Inventar: zeigt alle Items aus GameState.inventory.
## Item doppelklicken (oder Enter) -> Monster wählen -> Item wird benutzt.

var _list := ItemList.new()
var _items: Array[ItemData] = []
var _selected: ItemData = null   # null = wir zeigen Items, sonst Monster

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
	_show_items()

func _show_items() -> void:
	_selected = null
	_list.clear()
	_items = GameState.get_items()
	for item in _items:
		_list.add_item("%s  x%d" % [item.ItemName, GameState.item_count(item)], item.Icon)

func _on_activated(index: int) -> void:
	if _selected == null:
		var item := _items[index]
		if item.Category == Enums.ItemCategory.KEY_ITEM or item.UseContext == Enums.UseContext.BATTLE:
			return   # VM-Items und reine Kampf-Items kann man hier nicht benutzen
		_selected = item
		_list.clear()
		for monster in GameState.party:
			_list.add_item("%s  KP %d/%d" % [monster.get_display_name(), monster.current_hp, monster.get_max_hp()])
	else:
		if _selected.use_on(GameState.party[index]) and _selected.Consumable:
			GameState.remove_item(_selected)
		_show_items()
