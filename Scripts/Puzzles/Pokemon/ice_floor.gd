extends Area3D

## PLATZHALTER - Eisboden (Pokémon-Stil): wer drauftritt, rutscht in Laufrichtung, bis er gegen
## etwas stößt oder das Eis endet. Steuerung ist währenddessen gesperrt.
## Eine Area3D über die ganze Eisfläche ziehen. Steine/Hindernisse auf dem Eis beim PuzzleGrid
## als besetzt anmelden.

@export var grid: NodePath
@export var slide_speed: float = 6.0
@export var cracked_ice: bool = false      # Variante: Eis bricht nach dem zweiten Betreten (Ewigenau-Arena)

# TODO: var _sliding_bodies: Dictionary = {}   # Body -> Richtung (Vector2i)

func _ready() -> void:
	# TODO: body_entered / body_exited verbinden
	pass

func _on_body_entered(_body: Node3D) -> void:
	# TODO:
	# if _body ist der Spieler:
	#     Richtung = letzte Laufrichtung des Spielers, auf 4 Richtungen runden
	#     player.can_move = false
	#     _slide(_body, Richtung)
	pass

func _slide(_body: Node3D, _direction: Vector2i) -> void:
	# TODO:
	# var cell := grid.world_to_cell(_body.global_position)
	# while grid.is_free(cell + _direction) and grid.get_tile_kind(cell + _direction) == "eis":
	#     cell += _direction
	# Ein Feld weiter, falls dahinter normaler Boden ist
	# Tween zur Zielposition (Dauer = Felder / slide_speed), Rutsch-Sound
	# Am Ende: player.can_move = true
	# Liegt auf dem Ziel ein spin_tile, übernimmt das die Bewegung
	pass
