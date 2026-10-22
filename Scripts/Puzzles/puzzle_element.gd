extends Node3D
class_name PuzzleElement

## PLATZHALTER - Basisklasse für alle Rätsel-Teile in der Overworld (Schalter, Türen, Blöcke, Fackeln ...).
## Jedes Teil ist entweder AN oder AUS. Teile, die etwas auslösen (Schalter, Fackel), senden
## state_changed. Teile, die reagieren (Tür, Brücke, Truhe), hängen in `listens_to` und schauen,
## ob ihre Bedingung erfüllt ist.
##
## So benutzt man es in einer Map:
##   Raum (Node3D)
##   ├── PuzzleManager (puzzle_manager.gd)        Rätsel-Chef des Raums, speichert "gelöst"
##   ├── Schalter_A (floor_switch.gd)
##   ├── Schalter_B (floor_switch.gd)
##   └── Tür (puzzle_door.gd)                     listens_to = [Schalter_A, Schalter_B]

signal state_changed(element: PuzzleElement, active: bool)

@export var element_id: String = ""            # eindeutig im Raum, für Speichern und Debug
@export var start_active: bool = false
@export var listens_to: Array[NodePath] = []   # andere PuzzleElements, auf die dieses Teil reagiert
@export_enum("ALLE", "EINER", "KEINER") var condition: int = 0   # wie die listens_to-Teile kombiniert werden
@export var stays_solved: bool = false         # einmal AN, für immer AN (z. B. Tür, die offen bleibt)

var active: bool = false

func _ready() -> void:
	# TODO:
	# active = start_active
	# for path in listens_to:
	#     var other := get_node(path) as PuzzleElement
	#     other.state_changed.connect(_on_input_changed)
	# _apply_state(false)   # Startzustand ohne Animation zeigen
	pass

func set_active(value: bool, animate := true) -> void:
	# TODO:
	# if stays_solved and active: return
	# if value == active: return
	# active = value
	# _apply_state(animate)
	# state_changed.emit(self, active)
	pass

func toggle() -> void:
	# TODO: set_active(not active)
	pass

func reset() -> void:
	# TODO: zurück auf start_active, ohne Animation (wird vom PuzzleManager aufgerufen)
	pass

func _on_input_changed(_element: PuzzleElement, _value: bool) -> void:
	# TODO:
	# var states := listens_to.map(func(p): return get_node(p).active)
	# match condition:
	#     0: set_active(states.all(func(s): return s))      # ALLE
	#     1: set_active(states.any(func(s): return s))      # EINER
	#     2: set_active(not states.any(func(s): return s))  # KEINER
	pass

func _apply_state(_animate: bool) -> void:
	# TODO: in den Unterklassen überschreiben (Sprite wechseln, Tür hochfahren, Sound ...)
	pass
