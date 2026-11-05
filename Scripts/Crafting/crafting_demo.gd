extends Node

## Demo: gibt dir Material, stellt ein Amulett her, wertet es auf und öffnet die Werkstatt.
## Szene Szene/Prototype/crafting_demo.tscn öffnen und F6 drücken.

const KUPFER := preload("res://Resources/Materials/Kupfererz.tres")
const SILBER := preload("res://Resources/Materials/Silbererz.tres")
const RUBIN := preload("res://Resources/Items/Rubin.tres")
const REZEPT := preload("res://Resources/Recipes/Kupfer_Amulett.tres")

func _ready() -> void:
	GameState.new_game()
	GameState.add_item(KUPFER, 5)
	GameState.add_item(SILBER, 2)

	print("Hergestellt: ", REZEPT.craft(), " | Kupfer übrig: ", GameState.item_count(KUPFER))

	# Beim Fangen bekommt jedes Monster sein eigenes Exemplar
	var amulet: AmuletData = REZEPT.result.duplicate()
	amulet.engraving = "Für Tuubaa"
	print("Aufwerten: ", amulet.upgrade(), " | Stufe: ", AmuletData.Tier.keys()[amulet.tier], " | Fassungen: ", amulet.sockets())
	amulet.add_gem(RUBIN)
	print("Angriff-Bonus: ", amulet.stat_bonus("bonus_attack"), " | Fangbonus: ", amulet.catch_bonus())

	GameState.add_item(KUPFER, 3)
	var menu := CraftingMenu.new()
	add_child(menu)
	menu.open([REZEPT])
