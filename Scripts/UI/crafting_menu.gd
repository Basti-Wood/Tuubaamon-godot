extends PanelContainer
class_name CraftingMenu

## Einfaches Werkstatt-Menü: links Rezepte, rechts Zutaten, Gravur, Farbe und "Herstellen".

var recipes: Array[CraftingRecipe] = []
var bag: Dictionary = {}

var _list := ItemList.new()
var _info := Label.new()
var _engraving := LineEdit.new()
var _color := ColorPickerButton.new()
var _craft := Button.new()

func _ready() -> void:
	var row := HBoxContainer.new()
	var right := VBoxContainer.new()
	_list.custom_minimum_size = Vector2(200, 200)
	_engraving.placeholder_text = "Gravur (nur Schmuck)"
	_color.color = Color.WHITE
	_craft.text = "Herstellen"
	var close := Button.new()
	close.text = "Schließen"
	close.pressed.connect(hide)
	for c in [_info, _engraving, _color, _craft, close]:
		right.add_child(c)
	row.add_child(_list)
	row.add_child(right)
	add_child(row)
	_list.item_selected.connect(func(_i): _refresh())
	_craft.pressed.connect(_on_craft)
	hide()

func open(new_recipes: Array[CraftingRecipe], new_bag: Dictionary) -> void:
	recipes = new_recipes
	bag = new_bag
	_list.clear()
	for r in recipes:
		_list.add_item(r.recipe_name)
	if recipes.size() > 0:
		_list.select(0)
	_refresh()
	show()

func _selected() -> CraftingRecipe:
	var sel := _list.get_selected_items()
	return recipes[sel[0]] if sel.size() > 0 else null

func _refresh() -> void:
	var r := _selected()
	if r == null:
		_info.text = ""
		_craft.disabled = true
		return
	var text := ""
	for item in r.ingredients:
		text += "%s: %d / %d\n" % [item.ItemName, bag.get(item, 0), r.ingredients[item]]
	_info.text = text
	_craft.disabled = not r.can_craft(bag)

func _on_craft() -> void:
	var item := _selected().craft(bag)
	if item is AmuletData:
		item.engraving = _engraving.text
		item.color = _color.color
	if item:
		print("Hergestellt: ", item.ItemName)
	_refresh()
