extends Node

## Demo: baut Materialien, Rezepte und Inventar im Code und öffnet die Werkstatt.
## Szene Szene/Prototype/crafting_demo.tscn öffnen und F6 drücken.
## Im echten Spiel legst du Materialien und Rezepte als .tres in Resources/ an.

func _ready() -> void:
	var kupfer := _item("Kupfererz")
	var silber := _item("Silbererz")
	var rubin := GemData.new()
	rubin.ItemName = "Rubin"
	rubin.bonus_attack = 5

	var upgrade := CraftingRecipe.new()
	upgrade.ingredients = {silber: 2}

	var rohling := AmuletData.new()
	rohling.ItemName = "Kupfer-Amulett"
	rohling.Category = Enums.ItemCategory.CAPTURE
	rohling.upgrade_recipes = [upgrade]

	var recipe := CraftingRecipe.new()
	recipe.recipe_name = "Kupfer-Amulett"
	recipe.ingredients = {kupfer: 3}
	recipe.result = rohling

	var bag := {kupfer: 5, silber: 2}

	# Ablauf im Code testen
	var amulet: AmuletData = recipe.craft(bag)
	print("Hergestellt: ", amulet.ItemName, " | Kupfer übrig: ", bag[kupfer])
	print("Aufwerten: ", amulet.upgrade(bag), " | Stufe: ", AmuletData.Tier.keys()[amulet.tier], " | Fassungen: ", amulet.sockets())
	amulet.add_gem(rubin)
	print("Angriff-Bonus: ", amulet.stat_bonus("bonus_attack"), " | Fangbonus: ", amulet.catch_bonus())

	# Menü öffnen
	var menu := CraftingMenu.new()
	add_child(menu)
	menu.open([recipe], bag)

func _item(item_name: String) -> ItemData:
	var item := ItemData.new()
	item.ItemName = item_name
	return item
