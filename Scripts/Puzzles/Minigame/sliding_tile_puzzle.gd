extends GridPuzzle

## PLATZHALTER - Schiebe-Puzzle (15-Puzzle): ein Feld ist leer, Nachbarteile rutschen hinein.
## Ziel: das Bild (z. B. eine alte Wandmalerei in den Ruinen) wieder richtig zusammensetzen.
## level.start_state = Startbelegung (0 = leeres Feld), Zeile für Zeile.
## Wichtig: Nicht jede zufällige Belegung ist lösbar! Startzustand daher von Hand bauen
## oder aus dem gelösten Bild mit zufälligen GÜLTIGEN Zügen mischen.

# TODO: var _tiles: Array[int] = []        # Index = Feld, Wert = Bildteil (0 = leer)

func _load_level(_level: GridPuzzleLevel) -> void:
	# TODO:
	# if _level.start_state leer: gelöst aufbauen und 100 zufällige gültige Züge machen
	# else: _tiles = _level.start_state.duplicate()
	# Bild aus _level.background in grid_size Teile schneiden (AtlasTexture pro Teil)
	pass

func _handle_input(_event: InputEvent) -> void:
	# TODO:
	# Pfeiltaste = Teil NEBEN dem leeren Feld in diese Richtung schieben
	# Mausklick auf ein Nachbarteil des leeren Feldes = dieses Teil schieben
	# -> do_move(index_des_teils)
	pass

func _apply_move(_move) -> void:
	# TODO: Teil und leeres Feld tauschen, kurzer Tween
	pass

func _is_solved() -> bool:
	# TODO: _tiles == [1, 2, 3, ..., n-1, 0]  (oder level.goal_state, falls gesetzt)
	return false

func _get_state():
	# TODO: return _tiles.duplicate()
	return null

func _set_state(_state) -> void:
	# TODO: _tiles = _state; neu zeichnen
	pass
