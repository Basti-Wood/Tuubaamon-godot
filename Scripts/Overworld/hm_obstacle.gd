extends StaticBody3D

## PLATZHALTER - Hindernis, das nur mit einem VM-Item weggeht (Baum schneiden, Fels zerschlagen ...).
## VMs sind bei uns Items, keine Attacken (siehe design/spielmechaniken.md).

@export var required_item: Resource        # TODO: Typ auf ItemData ändern, Key-Item aus Resources/Items
@export var cleared_flag: String = ""      # Story-Flag, damit es weg bleibt

func _ready() -> void:
	# TODO: if GameState.has_flag(cleared_flag): queue_free()
	pass

func interact(player: Node) -> void:
	# TODO:
	# if Spieler hat required_item im Inventar:
	#     Animation abspielen, GameState.set_flag(cleared_flag), queue_free()
	# else:
	#     DialogueBox.show_lines(["Hier kommst du so nicht weiter."])
	pass
