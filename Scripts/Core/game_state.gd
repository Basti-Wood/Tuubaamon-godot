extends Node

## Globaler Spielzustand. Autoload "GameState" (siehe docs/tutorials/items-menues-speichern.md).
## Von überall erreichbar: GameState.add_item(...), GameState.has_flag(...) usw.

signal inventory_changed

var money: int = 0
var inventory: Dictionary = {}     # Item-Pfad -> Anzahl, z. B. {"res://Resources/Items/Potion.tres": 3}
var party: Array = []              # MonsterInstance, max. 6
var box: Array = []                # Monster, die nicht im Team sind
var story_flags: Dictionary = {}   # z. B. {"arena_1_besiegt": true}
var current_map: String = ""       # res://-Pfad der aktuellen Map
var spawn_point: String = ""       # Name des Spawn-Markers in der Map

func new_game() -> void:
	money = 500
	inventory.clear()
	party.clear()
	box.clear()
	story_flags.clear()
	current_map = ""
	spawn_point = ""
	inventory_changed.emit()

# ---------- Story-Flags ----------

func set_flag(flag: String, value := true) -> void:
	story_flags[flag] = value

func has_flag(flag: String) -> bool:
	return story_flags.get(flag, false)

# ---------- Inventar ----------

func add_item(item: ItemData, amount := 1) -> void:
	var path := item.resource_path
	inventory[path] = mini(inventory.get(path, 0) + amount, item.MaxStack)
	inventory_changed.emit()

func remove_item(item: ItemData, amount := 1) -> bool:
	var path := item.resource_path
	if inventory.get(path, 0) < amount:
		return false
	inventory[path] -= amount
	if inventory[path] <= 0:
		inventory.erase(path)
	inventory_changed.emit()
	return true

func has_item(item: ItemData) -> bool:
	return item != null and inventory.get(item.resource_path, 0) > 0

func item_count(item: ItemData) -> int:
	return inventory.get(item.resource_path, 0)

## Alle Items als Liste von ItemData (für Menüs).
func get_items() -> Array[ItemData]:
	var result: Array[ItemData] = []
	for path in inventory:
		result.append(load(path))
	return result
