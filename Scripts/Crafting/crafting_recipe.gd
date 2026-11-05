extends Resource
class_name CraftingRecipe

## Rezept: welche Materialien wie oft gebraucht werden und was herauskommt.
## Material kommt aus dem Inventar in GameState.

@export var recipe_name: String = ""
@export var ingredients: Dictionary[ItemData, int] = {}
@export var result: ItemData = null
@export var result_amount: int = 1

func can_craft() -> bool:
	for item in ingredients:
		if GameState.item_count(item) < ingredients[item]:
			return false
	return true

func consume() -> void:
	for item in ingredients:
		GameState.remove_item(item, ingredients[item])

## Zieht die Zutaten ab und legt das Ergebnis ins Inventar. false, wenn Material fehlt.
func craft() -> bool:
	if result == null or not can_craft():
		return false
	consume()
	GameState.add_item(result, result_amount)
	return true
