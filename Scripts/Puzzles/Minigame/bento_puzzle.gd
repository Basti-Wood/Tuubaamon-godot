extends GridPuzzle

## PLATZHALTER - Bento-Rätsel (wie "Bento Blocks"): alle Stücke müssen so in die Box,
## dass jedes freie Feld genau einmal belegt ist. Stücke dürfen gedreht werden.
## Die Form der Box kommt aus level.blocked_cells, die Stücke aus level.pieces.
##
## Story-Varianten mit derselben Logik:
## - Zerbrochene Steinplatten in den Ruinen zusammensetzen (design/spielmechaniken.md, Story-Ruinen)
## - Schmucksteine in ein Amulett einsetzen (Schmuck selbst herstellen)

# TODO: var _board: Dictionary = {}          # Vector2i -> Index des Stücks, das dort liegt
# TODO: var _placed: Dictionary = {}         # Index des Stücks -> {"pos": Vector2i, "rot": int, "flip": bool}
# TODO: var _held_piece: int = -1            # Stück, das gerade am Cursor hängt
# TODO: var _held_rot := 0
# TODO: var _cursor := Vector2i.ZERO

func _load_level(_level: GridPuzzleLevel) -> void:
	# TODO:
	# _board.clear(); _placed.clear()
	# Stücke in eine Ablage neben der Box legen (Liste unten oder rechts)
	pass

func _handle_input(_event: InputEvent) -> void:
	# TODO:
	# Ablage: Stück auswählen -> _held_piece
	# Auf dem Brett: Cursor bewegen, "rotate" dreht _held_rot
	# ui_accept: if can_place(...): do_move({"piece": _held_piece, "pos": _cursor, "rot": _held_rot})
	#            elif Feld unter Cursor ist belegt: Stück wieder aufnehmen (zählt auch als Zug)
	# Vorschau: Felder grün/rot färben, je nachdem ob das Stück passt
	pass

func can_place(_piece: int, _pos: Vector2i, _rot: int) -> bool:
	# TODO:
	# for c in level.pieces[_piece].get_cells(_rot, false):
	#     var cell := _pos + c
	#     if außerhalb, level.is_blocked(cell) oder _board.has(cell): return false
	# return true
	return false

func _apply_move(_move) -> void:
	# TODO: Stück in _board/_placed eintragen (oder entfernen, wenn es aufgenommen wurde), neu zeichnen
	pass

func _is_solved() -> bool:
	# TODO: alle Stücke liegen UND jedes nicht blockierte Feld ist belegt
	return false

func _get_state():
	# TODO: return {"board": _board.duplicate(), "placed": _placed.duplicate(true)}
	return null

func _set_state(_state) -> void:
	# TODO: _board und _placed aus _state übernehmen, neu zeichnen
	pass
