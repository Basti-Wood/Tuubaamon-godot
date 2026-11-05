extends Resource
class_name CraftingRecipe

## Rezept: welche Materialien wie oft gebraucht werden und was herauskommt.
## "bag" ist das Inventar als Dictionary { ItemData: Anzahl }.

@export var recipe_name: String = ""
@export var ingredients: Dictionary[ItemData, int] = {}
@export var result: ItemData = null
@export var result_amount: int = 1

func can_craft(bag: Dictionary) -> bool:
	for item in ingredients:
		if bag.get(item, 0) < ingredients[item]:
			return false
	return true

func consume(bag: Dictionary) -> void:
	for item in ingredients:
		bag[item] -= ingredients[item]
		if bag[item] <= 0:
			bag.erase(item)

## Gibt das hergestellte Item zurück (oder null). Schmuck wird kopiert, damit jedes Stück eigene Werte hat.
func craft(bag: Dictionary) -> ItemData:
	if result == null or not can_craft(bag):
		return null
	consume(bag)
	var item := result.duplicate() if result is AmuletData else result
	bag[item] = bag.get(item, 0) + result_amount
	return item
