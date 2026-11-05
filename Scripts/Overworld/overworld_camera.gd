extends Camera2D

## Kamera für die Overworld (2D). Als Kind an den Spieler hängen, dann folgt sie ihm.
## Bleibt innerhalb der Map: nimmt dafür den TileMapLayer in der Gruppe "boden".

func _ready() -> void:
	var boden := get_tree().get_first_node_in_group("boden") as TileMapLayer
	if boden == null:
		return
	var rect := boden.get_used_rect()
	var tile := boden.tile_set.tile_size
	var start := boden.global_position + Vector2(rect.position * tile)
	var ende := start + Vector2(rect.size * tile)
	limit_left = int(start.x)
	limit_top = int(start.y)
	limit_right = int(ende.x)
	limit_bottom = int(ende.y)
