extends PuzzleElement

## PLATZHALTER - Brüchiger Boden: hält einmal, beim zweiten Mal bricht er ein.
## Rätsel-Idee (Ewigenau-Arena): alle brüchigen Felder genau einmal betreten -> Treppe erscheint.
## Fällt man durch, landet man auf der Etage darunter (oder der Raum wird zurückgesetzt).
## AN = einmal betreten. Im PuzzleManager alle CrackedFloors als goal_elements eintragen.

@export var fall_target: NodePath          # optional: Marker3D auf der Etage darunter
@export var reset_on_fall: bool = true     # true = PuzzleManager.reset_puzzle() statt runterfallen

# TODO: var _steps := 0

func _on_body_entered(_body: Node3D) -> void:
	# TODO:
	# if _body ist nicht der Spieler: return
	# _steps += 1
	# if _steps == 1: set_active(true)      # Riss-Sprite
	# elif _steps >= 2: einbrechen -> Spieler fällt
	#     if reset_on_fall: PuzzleManager des Raums -> reset_puzzle()
	#     else: Spieler nach fall_target teleportieren
	pass

func reset() -> void:
	super()
	# TODO: _steps = 0, Boden wieder heil zeigen
	pass

func _apply_state(_animate: bool) -> void:
	# TODO: Sprite: heil / gerissen / Loch
	pass
