extends Node3D
class_name PuzzleGrid

## PLATZHALTER - Hilfs-Node für Rätsel, die auf Kacheln laufen (Blöcke schieben, Eis, Dreh-Felder).
## In der 3D-Welt bewegt sich der Spieler frei, aber Blöcke und Rutschen rasten auf einem Raster ein.
## Dieses Node rechnet zwischen Weltposition und Rasterfeld um und weiß, welche Felder frei sind.
##
## Ins Rätsel-Zimmer legen und mit der GridMap des Bodens verbinden (oder Größe von Hand eintragen).

@export var cell_size: float = 1.0
@export var grid_size: Vector2i = Vector2i(10, 10)
@export var floor_gridmap: NodePath                # optional: Boden-GridMap, aus der Wände gelesen werden

# TODO: var _blocked: Dictionary = {}               # Vector2i -> Node, das das Feld besetzt (Block, Fels, Wand)

func world_to_cell(world_pos: Vector3) -> Vector2i:
	# TODO: lokale Position berechnen, durch cell_size teilen, abrunden
	return Vector2i.ZERO

func cell_to_world(cell: Vector2i) -> Vector3:
	# TODO: Mitte des Feldes in Weltkoordinaten (y = Bodenhöhe)
	return Vector3.ZERO

func is_inside(cell: Vector2i) -> bool:
	# TODO: return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y
	return false

func is_free(cell: Vector2i) -> bool:
	# TODO: is_inside(cell) and nicht in _blocked and keine Wand in der GridMap
	return false

func occupy(cell: Vector2i, by: Node) -> void:
	# TODO: _blocked[cell] = by
	pass

func release(cell: Vector2i) -> void:
	# TODO: _blocked.erase(cell)
	pass

func get_occupant(cell: Vector2i) -> Node:
	# TODO: return _blocked.get(cell)
	return null

func get_tile_kind(cell: Vector2i) -> String:
	# TODO: Art des Bodens zurückgeben: "normal", "eis", "loch", "dreh_links" ...
	# Entweder aus der GridMap (Item-Name der MeshLibrary) oder von Rätsel-Nodes, die sich hier anmelden.
	return "normal"
