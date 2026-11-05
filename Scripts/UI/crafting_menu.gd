extends PanelContainer
class_name CraftingMenu

## Einfaches Werkstatt-Menü: links Rezepte, rechts Zutaten und "Herstellen".

var recipes: Array[CraftingRecipe] = []

var _list := ItemList.new()
var _info := Label.new()
var _craft := Button.new()

func _ready() -> void:
	var row := HBoxContainer.new()
	var right := VBoxContainer.new()
	_list.custom_minimum_size = Vector2(200, 200)
	_craft.text = "Herstellen"
	var close := Button.new()
	close.text = "Schließen"
	close.pressed.connect(hide)
	for c in [_info, _craft, close]:
		right.add_child(c)
	row.add_child(_list)
	row.add_child(right)
	add_child(row)
	_list.item_selected.connect(func(_i): _refresh())
	_craft.pressed.connect(_on_craft)
	hide()

func open(new_recipes: Array[CraftingRecipe]) -> void:
	recipes = new_recipes
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
		text += "%s: %d / %d\n" % [item.ItemName, GameState.item_count(item), r.ingredients[item]]
	_info.text = text
	_craft.disabled = not r.can_craft()

func _on_craft() -> void:
	if _selected().craft():
		print("Hergestellt: ", _selected().result.ItemName)
	_refresh()
