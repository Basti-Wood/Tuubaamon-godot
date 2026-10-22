extends Node3D

## PLATZHALTER - Stärke-Fels (Pokémon-Stil): lässt sich nur mit dem passenden VM-Werkzeug schieben.
## VMs sind bei uns Items (siehe Scripts/Overworld/hm_obstacle.gd und design/spielmechaniken.md).
## Funktioniert wie ../Zelda/pushable_block.gd, nur mit Item-Abfrage und ohne Verzögerung.
## Kann in ein Loch geschoben werden (boulder_hole.gd) und drückt schwere Bodenschalter.

@export var grid: NodePath                 # PuzzleGrid im Raum
@export var required_item: Resource        # TODO: Typ auf ItemData ändern (z. B. "Hebel-Relikt")
@export var push_time: float = 0.35

# TODO: var cell: Vector2i
# TODO: var _start_cell: Vector2i
# TODO: var _strength_active := false      # wie in Pokémon: einmal "Stärke einsetzen?" pro Raum

func interact(_player: Node) -> void:
	# TODO:
	# if _strength_active: return
	# if Spieler hat required_item:
	#     Dialog "Mit dem Hebel-Relikt kannst du den Felsen bewegen!" -> _strength_active = true
	# else:
	#     Dialog "Ein schwerer Felsen. Mit dem richtigen Werkzeug ..."
	pass

func try_push(direction: Vector2i) -> bool:
	# TODO:
	# if not _strength_active: return false
	# var target := cell + direction
	# if grid.get_occupant(target) ist ein BoulderHole: in das Loch schieben (hole.fill(self)); return true
	# if not grid.is_free(target): return false
	# Feld wechseln, Tween, Rumpel-Sound + kleiner Kamera-Wackler
	return false

func reset() -> void:
	# TODO: zurück auf _start_cell, _strength_active = false
	pass
