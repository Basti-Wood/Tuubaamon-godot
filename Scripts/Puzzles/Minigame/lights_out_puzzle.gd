extends GridPuzzle

## PLATZHALTER - "Lichter aus"-Rätsel: ein Feld drücken schaltet es und seine 4 Nachbarn um.
## Ziel: alle aus (oder alle an). Passt gut als Runen-/Kristall-Tafel in Ruinen.
## level.start_state = 1 für an, 0 für aus, Zeile für Zeile.
## Auch hier: Startzustand am besten durch zufällige Züge aus dem Ziel erzeugen, dann ist er lösbar.

# TODO: var _lights: Array[int] = []

func _load_level(_level: GridPuzzleLevel) -> void:
	# TODO: _lights = _level.start_state.duplicate() (oder zufällig wie oben beschrieben)
	pass

func _handle_input(_event: InputEvent) -> void:
	# TODO: Cursor bewegen, ui_accept / Klick -> do_move(Feld unter dem Cursor)
	pass

func _apply_move(_move) -> void:
	# TODO: Feld und Nachbarn (oben, unten, links, rechts, sofern im Brett) umschalten
	pass

func _is_solved() -> bool:
	# TODO: alle 0 (oder == level.goal_state)
	return false

func _get_state():
	# TODO: return _lights.duplicate()
	return null

func _set_state(_state) -> void:
	# TODO: _lights = _state; neu zeichnen
	pass
