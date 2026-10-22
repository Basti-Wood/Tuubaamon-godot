extends Node
class_name PuzzleManager

## PLATZHALTER - Rätsel-Chef eines Raums oder einer ganzen Dungeon-Etage.
## Kennt alle PuzzleElements darunter bzw. im Raum, merkt sich, ob das Rätsel gelöst ist,
## setzt es zurück (z. B. Eis-Rätsel verbockt) und speichert den Fortschritt über GameState.
##
## Ein Rätsel ist gelöst, wenn alle `goal_elements` AN sind.
## Beispiel: Tür geht auf, wenn beide Schalter gedrückt sind -> goal_elements = [Tür].

signal puzzle_solved(puzzle_id: String)
signal puzzle_reset(puzzle_id: String)

@export var puzzle_id: String = ""                 # z. B. "wald_dungeon_raum_3", wird zum Story-Flag
@export var goal_elements: Array[NodePath] = []    # diese Teile müssen AN sein
@export var reward_on_solve: Array[NodePath] = []  # Teile, die beim Lösen AN gehen (Truhe, Brücke, Treppe)
@export var solved_sound: AudioStream              # das "Zelda-Jingle"
@export var allow_reset: bool = true               # Spieler darf zurücksetzen (Eis, Blöcke, Bento ...)

# TODO: var _elements: Array[PuzzleElement] = []
# TODO: var solved := false

func _ready() -> void:
	# TODO:
	# Alle PuzzleElements im Raum einsammeln (Kinder des Eltern-Nodes, rekursiv)
	# if GameState.has_flag(_flag()):
	#     solved = true
	#     Ziel- und Belohnungs-Teile ohne Animation auf AN setzen, damit der Raum gelöst aussieht
	#     return
	# for path in goal_elements: get_node(path).state_changed.connect(_check_solved)
	pass

func _check_solved(_element: PuzzleElement, _active: bool) -> void:
	# TODO:
	# if solved: return
	# if alle goal_elements sind active:
	#     solved = true
	#     GameState.set_flag(_flag())
	#     Belohnungen aktivieren, solved_sound abspielen
	#     Optional: Kamera kurz zur Belohnung schwenken (wie in Zelda)
	#     puzzle_solved.emit(puzzle_id)
	pass

func reset_puzzle() -> void:
	# TODO:
	# if solved or not allow_reset: return
	# for e in _elements: e.reset()
	# Spieler zum Raum-Eingang (Marker3D "puzzle_start") setzen
	# puzzle_reset.emit(puzzle_id)
	pass

func _flag() -> String:
	return "puzzle_" + puzzle_id
