extends RefCounted

## PLATZHALTER - Gegner-KI: welche Attacke der Gegner wählt.

func choose_move(attacker, defender) -> MoveData:
	# TODO:
	# einfache Variante: zufällige Attacke mit AP > 0
	# bessere Variante: Attacken nach erwartetem Schaden gewichten
	#   (TypeChart.get_effectiveness, Stärke, Genauigkeit)
	# Trainer-KI kann zusätzlich Items benutzen oder Monster wechseln
	return null

func roll_timing_tier(attacker) -> int:
	# TODO: Gegner treffen ihr Timing auch in 5 Stufen.
	# ActionCommand.roll_enemy_tier(precision) benutzen, precision aus einem Stat des Gegners
	return 0
