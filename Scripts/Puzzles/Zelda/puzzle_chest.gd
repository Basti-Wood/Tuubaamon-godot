extends PuzzleElement

## PLATZHALTER - Truhe, die erst erscheint, wenn ein Rätsel gelöst ist (der Klassiker).
## Im PuzzleManager unter reward_on_solve eintragen. Inhalt: Item, Schlüssel, Schmuckstein ...

@export var content: Resource              # TODO: Typ auf ItemData ändern
@export var amount: int = 1
@export var opened_flag: String = ""

func _apply_state(_animate: bool) -> void:
	# TODO: AUS = unsichtbar + keine Kollision, AN = mit Plopp und Rauchwolke erscheinen
	pass

func interact(_player: Node) -> void:
	# TODO:
	# if not active or GameState.has_flag(opened_flag): return
	# Inhalt ins Inventar (GameState.player), Dialog "Du hast X erhalten!"
	# GameState.set_flag(opened_flag), Sprite auf "offen"
	pass
