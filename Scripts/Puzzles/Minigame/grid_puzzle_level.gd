extends Resource
class_name GridPuzzleLevel

## PLATZHALTER - ein Level für ein Raster-Rätsel (Bento, Schiebe-Puzzle, Lichter aus ...).
## Pro Rätsel eine .tres in Resources/Puzzles/ anlegen (Vorlage: 1GridPuzzleTemplate.tres).
## Dieselbe Resource passt für alle Rätselarten; was nicht gebraucht wird, bleibt leer.

@export var level_name: String = ""
@export_multiline var hint: String = ""                # Hinweis-Text (wichtig für das "unmögliche" 3-Sterne-Rätsel)
@export var grid_size: Vector2i = Vector2i(4, 4)
@export var blocked_cells: Array[Vector2i] = []        # Felder, die nicht benutzt werden können (Form der Bento-Box)
@export var pieces: Array[PuzzlePieceData] = []        # Bento: die Stücke, die rein müssen
@export var start_state: Array[int] = []               # Schiebe-Puzzle / Lichter aus: Startbelegung, Zeile für Zeile
@export var goal_state: Array[int] = []                # leer = Standard-Ziel der Rätselart
@export var star_moves: Array[int] = [0, 0, 0]         # Züge für 3 / 2 / 1 Stern(e), 0 = keine Sterne
@export var background: Texture2D                      # z. B. Bild der Steintafel, Bento-Box

func is_blocked(_cell: Vector2i) -> bool:
	# TODO: return _cell in blocked_cells
	return false
