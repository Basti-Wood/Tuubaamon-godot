extends Node3D

## PLATZHALTER - Schiebeblock (Zelda-Stil): Spieler läuft dagegen und schiebt ihn ein Feld weiter.
## Rastet auf dem PuzzleGrid ein. Kein PuzzleElement, weil er selbst nichts schaltet;
## er drückt aber Bodenschalter (floor_switch.gd mit needs_heavy).
## Aufbau: PushableBlock (Node3D, dieses Skript)
##           ├── MeshInstance3D oder Sprite3D
##           └── AnimatableBody3D + CollisionShape3D (damit der Spieler nicht durchläuft)
##
## Zum Strength-Felsen aus Pokémon siehe ../Pokemon/strength_boulder.gd (gleiche Idee, braucht aber ein VM-Item).

@export var grid: NodePath                 # PuzzleGrid im Raum
@export var push_time: float = 0.4         # Sekunden für ein Feld
@export var push_delay: float = 0.3        # so lange muss der Spieler dagegen drücken (wie in Zelda)
@export var only_once: bool = false        # nur ein Feld weit schiebbar ("Block bewegt sich nicht mehr")
@export var can_pull: bool = false         # Ziehen mit gedrückter Interagieren-Taste

# TODO: var cell: Vector2i
# TODO: var _moving := false
# TODO: var _push_timer := 0.0
# TODO: var _start_cell: Vector2i          # für reset()

func _ready() -> void:
	# TODO: cell = grid.world_to_cell(global_position); auf Feldmitte setzen; grid.occupy(cell, self)
	pass

func try_push(direction: Vector2i) -> bool:
	# TODO: vom Spieler aufgerufen, wenn er push_delay lang dagegen läuft
	# if _moving: return false
	# var target := cell + direction
	# if not grid.is_free(target): return false
	# grid.release(cell); cell = target; grid.occupy(cell, self)
	# Tween auf grid.cell_to_world(cell), Schiebe-Sound
	# Falls Ziel ein Loch ist: Block fällt rein und wird zu Boden (siehe ../Pokemon/boulder_hole.gd)
	return false

func reset() -> void:
	# TODO: zurück auf _start_cell (vom PuzzleManager aufgerufen)
	pass
