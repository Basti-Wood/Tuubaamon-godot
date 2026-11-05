extends Node

## Autoload "SceneSwitcher": Wechsel zwischen Maps und zwischen Overworld und Kampf.
## Der Map-Wechsel (go_to_map) ist noch PLATZHALTER.

signal battle_ended(result: String)    # "win", "lose", "caught", "fled"

const BATTLE_SCENE := "res://Szene/Battle/battle_scene.tscn"

var _overworld: Node      # wird während des Kampfes pausiert und versteckt statt gelöscht
var _battle: Node

func go_to_map(map_path: String, spawn_name: String) -> void:
	# TODO:
	# Bildschirm abblenden (Fade)
	# get_tree().change_scene_to_file(map_path)
	# warten bis geladen, dann Spieler an den Marker "spawn_name" setzen
	# GameState.current_map = map_path; GameState.spawn_point = spawn_name
	# Bildschirm einblenden
	pass

func start_battle(enemy_team: Array, is_trainer := false) -> void:
	if _battle:
		return
	# TODO: Übergangs-Animation (Paper-Mario-Stil, z. B. Bildschirm zerbricht/dreht sich)
	_overworld = get_tree().current_scene
	_overworld.process_mode = Node.PROCESS_MODE_DISABLED
	_overworld.set("visible", false)

	_battle = load(BATTLE_SCENE).instantiate()
	get_tree().root.add_child(_battle)
	_battle.battle_finished.connect(end_battle)
	_battle.setup(GameState.party, enemy_team, is_trainer)

func end_battle(result: String) -> void:
	_battle.queue_free()
	_battle = null
	_overworld.process_mode = Node.PROCESS_MODE_INHERIT
	_overworld.set("visible", true)

	if result == "lose":
		# TODO: zum letzten Heilpunkt (go_to_map). Bis dahin wird das Team einfach geheilt.
		for monster in GameState.party:
			monster.current_hp = monster.get_max_hp()
	battle_ended.emit(result)
