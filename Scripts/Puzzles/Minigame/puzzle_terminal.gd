extends PuzzleElement

## PLATZHALTER - Objekt in der Overworld, das ein Puzzlespiel-Rätsel öffnet
## (Steintafel, Bento-Box auf dem Tisch, Runen-Wand ...). Wird AN, wenn das Rätsel gelöst ist,
## kann also wie ein Schalter Türen öffnen (im PuzzleManager als goal_element eintragen).
##
## Sterne: das Ergebnis wird als Flag gespeichert, damit der optionale Puzzle-Dungeon
## (3 Sterne, das letzte Rätsel ist mit 3 Sternen unmöglich) Sterne zählen kann.

@export var puzzle_scene: PackedScene      # z. B. Szene/Puzzles/bento_puzzle.tscn
@export var level: GridPuzzleLevel
@export var solved_flag: String = ""
@export var min_stars_to_open: int = 0     # 0 = lösen reicht, 1-3 = so viele Sterne nötig

func _ready() -> void:
	super()
	# TODO: if GameState.has_flag(solved_flag): set_active(true, false)
	pass

func interact(_player: Node) -> void:
	# TODO:
	# var puzzle := puzzle_scene.instantiate() as GridPuzzle
	# puzzle.level = level
	# In eine CanvasLayer über der Overworld hängen, Spieler sperren
	# var result = await puzzle.finished      # [solved, stars]
	# Spieler entsperren
	# if solved:
	#     Beste Sterne merken: GameState.story_flags["sterne_" + solved_flag] = max(alt, stars)
	#     if stars >= min_stars_to_open:
	#         GameState.set_flag(solved_flag); set_active(true)
	#     else:
	#         Dialog "Gelöst, aber es geht noch besser ..."
	pass

func _apply_state(_animate: bool) -> void:
	# TODO: Tafel leuchtet / Bento-Box ist zu, Interaktion zeigt nur noch die Sterne
	pass
