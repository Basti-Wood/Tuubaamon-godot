extends Resource
class_name PuzzlePieceData

## PLATZHALTER - ein Teil für Raster-Rätsel (Bento-Stück, Steinplatten-Scherbe, Tetris-Form ...).
## Die Form ist eine Liste von Feldern relativ zur linken oberen Ecke.
## Beispiel L-Form: [(0,0), (0,1), (0,2), (1,2)]

@export var piece_name: String = ""
@export var cells: Array[Vector2i] = [Vector2i(0, 0)]
@export var texture: Texture2D             # Bild über die ganze Form (wird in Felder zerschnitten oder gestreckt)
@export var can_rotate: bool = true
@export var can_flip: bool = false
@export var color: Color = Color.WHITE     # Ersatzfarbe, solange es kein Bild gibt

func get_cells(_rotation: int, _flipped: bool) -> Array[Vector2i]:
	# TODO:
	# Jedes Feld um _rotation * 90° drehen: (x, y) -> (-y, x)
	# if _flipped: x spiegeln
	# Danach so verschieben, dass das kleinste x und y wieder 0 sind
	return cells

func get_size(_rotation: int, _flipped: bool) -> Vector2i:
	# TODO: Breite und Höhe der gedrehten Form (max x + 1, max y + 1)
	return Vector2i.ONE
