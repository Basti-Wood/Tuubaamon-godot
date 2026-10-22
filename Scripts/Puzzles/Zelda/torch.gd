extends PuzzleElement

## PLATZHALTER - Fackel (Zelda-Stil): wird mit Feuer angezündet. Oft: alle Fackeln an -> Tür auf.
## Anzünden: mit einem Feuer-Monster im Team (passt zu "Werkzeug + passender Typ", design/spielmechaniken.md)
## oder mit einer brennenden Fackel/einem Feuer-Item.

@export var burn_seconds: float = 0.0      # > 0 = geht nach X Sekunden wieder aus (alle schnell anzünden)
@export var needs_fire_type: bool = true

func interact(_player: Node) -> void:
	# TODO:
	# if active: return
	# if needs_fire_type and kein Feuer-Monster im Team (GameState.party, Enums.Type.FIRE):
	#     DialogueBox.show_lines(["Hier könnte man etwas anzünden ..."]); return
	# set_active(true)
	# if burn_seconds > 0: Timer starten, danach set_active(false)
	pass

func _apply_state(_animate: bool) -> void:
	# TODO: Flammen-Sprite (AnimatedSprite3D) + OmniLight3D an/aus
	pass
