extends StaticBody2D
class_name AbilityObstacle

## Hindernis in der Overworld, das nur mit einer Spieler-Fähigkeit weggeht
## (Fels zerschlagen, Wand hochklettern ...). Siehe docs/tutorials/spieler-faehigkeiten.md

@export var required_ability: String = "zerschmettern"
@export_multiline var blocked_text: String = "Ein großer Fels. Vielleicht kann man ihn zerschlagen?"

## Wird vom Spieler aufgerufen, wenn er davor steht und "interact" drückt.
func interact(player_data: PlayerData) -> bool:
	if not player_data.has_ability(required_ability):
		print(blocked_text)  # später: DialogueBox
		return false
	queue_free()
	return true
