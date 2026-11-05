extends Node

## Speichern und Laden von Spielständen als JSON. Autoload "SaveManager".
## Einstellungen (Lautstärke, Tasten) speichert der ConfigManager, hier geht es nur um den Spielstand.

const SAVE_DIR := "user://saves/"

func _path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot

func save_game(slot: int) -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var data := {
		"version": 1,
		"money": GameState.money,
		"inventory": GameState.inventory,
		"party": GameState.party.map(func(m): return m.to_dict()),
		"box": GameState.box.map(func(m): return m.to_dict()),
		"story_flags": GameState.story_flags,
		"map": GameState.current_map,
		"spawn": GameState.spawn_point,
	}
	var file := FileAccess.open(_path(slot), FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

func load_game(slot: int) -> bool:
	if not has_save(slot):
		return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(_path(slot)))
	if data == null:
		return false
	GameState.money = int(data["money"])
	GameState.inventory.clear()
	for path in data["inventory"]:
		GameState.inventory[path] = int(data["inventory"][path])   # JSON macht aus Zahlen floats
	GameState.party.assign(data["party"].map(func(d): return MonsterInstance.from_dict(d)))
	GameState.box.assign(data["box"].map(func(d): return MonsterInstance.from_dict(d)))
	GameState.story_flags = data["story_flags"]
	GameState.current_map = data["map"]
	GameState.spawn_point = data["spawn"]
	GameState.inventory_changed.emit()
	return true

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_path(slot))
