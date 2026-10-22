extends Node

## PLATZHALTER - Wechsel zwischen Maps und zwischen Overworld und Kampf.
## Später als Autoload "SceneSwitcher" eintragen.

# TODO: var _overworld_scene: Node     # wird während des Kampfes versteckt statt gelöscht

func go_to_map(map_path: String, spawn_name: String) -> void:
	# TODO:
	# Bildschirm abblenden (Fade)
	# get_tree().change_scene_to_file(map_path)
	# warten bis geladen, dann Spieler an den Marker "spawn_name" setzen
	# GameState.current_map = map_path; GameState.spawn_point = spawn_name
	# Bildschirm einblenden
	pass

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
