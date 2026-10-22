extends Node3D

## PLATZHALTER - Pfeil-/Drehfeld (Pokémon-Stil, Team-Rocket-Versteck): wer drauftritt, wird in
## Pfeilrichtung weitergeschoben, bis er auf einem Stopp-Feld oder vor einer Wand landet.
## Für Rätsel, in denen man die richtige Reihenfolge der Felder finden muss.
## Aufbau: SpinTile (Node3D, dieses Skript)
##           ├── Sprite3D (Pfeil, flach auf dem Boden)
##           └── Area3D + CollisionShape3D

@export var grid: NodePath
@export var direction: Vector2i = Vector2i(0, -1)   # Pfeilrichtung
@export var is_stop_tile: bool = false              # Stopp-Feld beendet die Bewegung
@export var move_speed: float = 5.0

func _ready() -> void:
	# TODO:
	# Pfeil-Sprite nach direction drehen
	# Area3D body_entered verbinden
	pass

func _on_body_entered(_body: Node3D) -> void:
	# TODO:
	# if is_stop_tile: player.can_move = true; return
	# player.can_move = false
	# Spieler-Sprite dreht sich (Dreh-Animation)
	# Spieler Feld für Feld in direction schieben, bis Wand oder ein anderes SpinTile
	# (das nächste SpinTile übernimmt dann über sein eigenes body_entered)
	pass
