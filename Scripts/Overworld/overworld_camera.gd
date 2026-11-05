extends Camera2D

## Kamera als Kind des Spielers. Bleibt innerhalb der Map, wenn die
## Boden-TileMapLayer der Map in der Gruppe "ground" ist.

func _ready() -> void:
	var ground := get_tree().get_first_node_in_group("ground") as TileMapLayer
	if ground == null:
		return
	var rect := ground.get_used_rect()
	var tile := Vector2(ground.tile_set.tile_size)
	var top_left := ground.global_position + Vector2(rect.position) * tile
	var bottom_right := top_left + Vector2(rect.size) * tile
	limit_left = int(top_left.x)
	limit_top = int(top_left.y)
	limit_right = int(bottom_right.x)
	limit_bottom = int(bottom_right.y)
