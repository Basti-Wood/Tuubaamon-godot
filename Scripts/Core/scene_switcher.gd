extends Node

## PLATZHALTER - Wechsel zwischen Maps und zwischen Overworld und Kampf.
## Als Autoload "SceneSwitcher" eingetragen.

# TODO: var _overworld_scene: Node     # wird während des Kampfes versteckt statt gelöscht

func go_to_map(map_path: String, spawn_name: String) -> void:
	# TODO: Bildschirm abblenden (Fade) und GameState.current_map/spawn_point setzen
	get_tree().change_scene_to_file.call_deferred(map_path)
	await get_tree().scene_changed
	var marker := get_tree().current_scene.find_child(spawn_name) as Node2D
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if marker and player:
		player.global_position = marker.global_position

func start_battle(enemy_team: Array, is_trainer := false) -> void:
	# TODO:
	# Übergangs-Animation (Paper-Mario-Stil, z. B. Bildschirm zerbricht/dreht sich)
	# Overworld pausieren und verstecken (nicht löschen, damit die Position erhalten bleibt)
	# Szene/Battle/battle_scene.tscn instanziieren und battle_scene.setup(GameState.party, enemy_team, is_trainer)
	# auf battle_scene.battle_finished warten -> end_battle(result)
	pass

func end_battle(result: String) -> void:
	# TODO: Kampfszene entfernen, Overworld wieder anzeigen und fortsetzen
	# bei Niederlage: zum letzten Heilpunkt
	pass
