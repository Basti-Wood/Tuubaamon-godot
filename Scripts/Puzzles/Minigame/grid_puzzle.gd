extends Control
class_name GridPuzzle

## PLATZHALTER - Basis für Puzzlespiel-Rätsel, die als eigenes Fenster über der Overworld laufen
## (Bento Blocks, Schiebe-Puzzle, Lichter aus, Steintafeln zusammensetzen ...).
## Ist ein 2D-UI (Control), kein 3D. Geöffnet wird es von puzzle_terminal.gd in der Overworld.
##
## Aufbau einer Rätsel-Szene, z. B. Szene/Puzzles/bento_puzzle.tscn:
##   BentoPuzzle (Control, bento_puzzle.gd)       Theme: Assets/UI/main_theme.tres
##   ├── ColorRect (Hintergrund, halbtransparent)
##   ├── Board (Control)                         hier werden die Felder gezeichnet
##   ├── MovesLabel (Label)                      "Züge: 12"
##   ├── StarsLabel (Label)                      ★★☆
##   └── Buttons (HBoxContainer): Rückgängig, Neustart, Hinweis, Aufgeben
##
## Unterklassen überschreiben die _-Funktionen unten, den Rest (Züge zählen, Rückgängig,
## Sterne, Lösen, Schließen) macht diese Basis.

signal finished(solved: bool, stars: int)

@export var level: GridPuzzleLevel
@export var cell_pixels: int = 64

var moves: int = 0
# TODO: var _undo_stack: Array = []        # vorherige Zustände (Kopie von _get_state())
# TODO: var _solved := false

func _ready() -> void:
	# TODO:
	# _load_level(level)
	# Board-Größe = level.grid_size * cell_pixels, Brett zeichnen
	# Spieler in der Overworld sperren (player.can_move = false), solange das Fenster offen ist
	pass

func _unhandled_input(_event: InputEvent) -> void:
	# TODO:
	# Steuerung mit Controller/Tastatur UND Maus:
	#   ui_left/right/up/down = Cursor bewegen, ui_accept = Teil nehmen/ablegen oder Feld drücken
	#   "rotate" (neue Taste) = Teil drehen, ui_cancel = Teil zurücklegen / Fenster schließen
	#   "undo" (neue Taste) = undo()
	# Eingaben an _handle_input(event) der Unterklasse weitergeben
	pass

func do_move(_move) -> void:
	# TODO: von Unterklassen nach jedem gültigen Zug aufrufen
	# _undo_stack.push_back(_get_state())
	# _apply_move(_move); moves += 1; Anzeige aktualisieren
	# if _is_solved(): _on_solved()
	pass

func undo() -> void:
	# TODO: if _undo_stack: _set_state(_undo_stack.pop_back()); moves -= 1  (oder Rückgängig zählt als Zug, Geschmackssache)
	pass

func restart() -> void:
	# TODO: _load_level(level); moves = 0; _undo_stack.clear()
	pass

func get_stars() -> int:
	# TODO:
	# if level.star_moves == [0,0,0]: return 0          # Rätsel ohne Sterne
	# if moves <= level.star_moves[0]: return 3
	# if moves <= level.star_moves[1]: return 2
	# return 1
	return 0

func give_up() -> void:
	# TODO: finished.emit(false, 0); Fenster schließen
	pass

func _on_solved() -> void:
	# TODO:
	# _solved = true; Eingaben sperren
	# Gewinn-Animation + Jingle, Sterne zeigen
	# kurz warten, dann finished.emit(true, get_stars()) und Fenster schließen
	pass

# --- Von Unterklassen überschreiben ---

func _load_level(_level: GridPuzzleLevel) -> void:
	pass

func _handle_input(_event: InputEvent) -> void:
	pass

func _apply_move(_move) -> void:
	pass

func _is_solved() -> bool:
	return false

func _get_state():
	return null

func _set_state(_state) -> void:
	pass
