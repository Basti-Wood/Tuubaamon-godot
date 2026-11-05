extends StaticBody2D

## Hindernis, das nur mit einem VM-Item weggeht (Baum schneiden, Fels zerschlagen ...).
## VMs sind bei uns Items, keine Attacken (siehe design/spielmechaniken.md).
## Der Spieler ruft interact(self) auf, wenn er davor steht und "interact" drückt.

@export var required_item: ItemData        # Key-Item aus Resources/Items, z. B. Axt.tres
@export var cleared_flag: String = ""      # Story-Flag, damit es weg bleibt, z. B. "baum_route1_weg"

func _ready() -> void:
	if cleared_flag != "" and GameState.has_flag(cleared_flag):
		queue_free()

func interact(_player: Node) -> void:
	if GameState.has_item(required_item):
		GameState.set_flag(cleared_flag)
		queue_free()   # hier später eine Animation abspielen
	else:
		print("Hier kommst du so nicht weiter.")   # später: DialogueBox
