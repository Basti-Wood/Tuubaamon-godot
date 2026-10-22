extends PuzzleElement

## PLATZHALTER - Tür, Gitter, Brücke oder Treppe, die erscheint/öffnet, wenn ihre Bedingung erfüllt ist.
## Im Inspector `listens_to` mit Schaltern füllen und `condition` wählen (ALLE / EINER / KEINER).
## Für Türen mit Schlüssel siehe locked_door.gd.

@export_enum("TUER", "GITTER", "BRUECKE", "TREPPE") var kind: int = 0

func _apply_state(_animate: bool) -> void:
	# TODO:
	# AN  = offen: Kollision aus, Tür hochfahren / Brücke ausfahren / Treppe einblenden
	# AUS = zu: umgekehrt
	# Bei _animate: Tween + Sound, sonst sofort
	pass
