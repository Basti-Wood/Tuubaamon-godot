extends PuzzleElement

## PLATZHALTER - Schalter, den man anschlägt, statt draufzutreten (Kristallschalter in Zelda).
## Wird über interact() vom Spieler ausgelöst. Später auch durch Attacken oder Werkzeuge
## (z. B. ein geworfener Gegenstand), deshalb gibt es hit().

@export var timer_seconds: float = 0.0   # > 0 = geht nach X Sekunden wieder aus (Zeit-Rätsel)
@export var color_group: String = ""     # optional: alle Schalter einer Farbe wechseln gemeinsam (rot/blau-Blöcke)

func interact(_player: Node) -> void:
	# TODO: hit()
	pass

func hit() -> void:
	# TODO:
	# toggle()
	# if timer_seconds > 0 and active:
	#     await get_tree().create_timer(timer_seconds).timeout
	#     set_active(false)
	# Ticken-Sound während der Timer läuft
	# if color_group != "": get_tree().call_group("puzzle_color_" + color_group, "toggle")
	pass

func _apply_state(_animate: bool) -> void:
	# TODO: Farbe des Kristalls wechseln
	pass
