extends Control

## PLATZHALTER - Pausemenü in der Overworld.
## Die Szene dazu gibt es schon: Szene/main menue/game_options.tscn (noch ohne Skript).

func open() -> void:
	# TODO: get_tree().paused = true; show()   (process_mode dieses Menüs auf ALWAYS stellen)
	pass

func _on_resume_pressed() -> void:
	# TODO: get_tree().paused = false; hide()
	pass

func _on_party_pressed() -> void:
	# TODO: PartyMenu öffnen
	pass

func _on_save_pressed() -> void:
	# TODO: SaveManager.save_game(aktueller Slot)
	pass

func _on_quit_pressed() -> void:
	# TODO: zurück ins Hauptmenü (vorher fragen, ob gespeichert werden soll)
	pass
