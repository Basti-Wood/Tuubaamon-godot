# Story-Flags und Cutscenes (inkl. Flashbacks)

Brainstorm: Flashback-Zeitreisen (Tutorial, Berliner Mauer, geben Items/Fähigkeiten), Haus-Dungeon am Anfang, Ömer-Hauptstrang.

## 1. Story-Flags

Alles, was die Story sich merken muss, ist ein Flag in `GameState`. Fülle die TODOs in `Scripts/Core/game_state.gd`:

```gd
signal flag_changed(flag: String)
var story_flags: Dictionary = {}

func set_flag(flag: String, value := true) -> void:
	story_flags[flag] = value
	flag_changed.emit(flag)

func has_flag(flag: String) -> bool:
	return story_flags.get(flag, false)
```

Dann in *Projekt > Projekteinstellungen > Globals* `game_state.gd` als Autoload **GameState** eintragen.

Namensregel: `ort_ereignis`, z. B. `haus_ausgebrochen`, `mutter_besiegt`, `flashback_mauer_gesehen`.

## 2. Cutscene mit AnimationPlayer

Einfachster Weg: Eine Cutscene ist ein `AnimationPlayer` in der Map. Darin animierst du Positionen von Spieler/NPCs und rufst per **Call Method Track** Funktionen auf (z. B. Dialog).

Script `Scripts/Story/cutscene_trigger.gd` auf eine `Area2D`:

```gdscript
extends Area2D

## Startet eine Cutscene einmal, wenn der Spieler reinläuft.

@export var animation_player: AnimationPlayer
@export var animation_name := "cutscene"
@export var done_flag := ""       # z. B. "wald_oemer_gesehen"
@export var required_flag := ""   # optional: nur wenn dieses Flag schon gesetzt ist

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if GameState.has_flag(done_flag):
		return
	if required_flag != "" and not GameState.has_flag(required_flag):
		return
	body.set_physics_process(false)   # Spieler sperren
	animation_player.play(animation_name)
	await animation_player.animation_finished
	body.set_physics_process(true)
	GameState.set_flag(done_flag)
```

## 3. NPC/Objekt nur bei Flag sichtbar

```gdscript
extends Node2D

## Zeigt diesen Knoten nur, wenn ein Flag gesetzt (oder nicht gesetzt) ist.

@export var flag := ""
@export var show_if_set := true

func _ready() -> void:
	GameState.flag_changed.connect(func(_f): _update())
	_update()

func _update() -> void:
	visible = GameState.has_flag(flag) == show_if_set
	process_mode = PROCESS_MODE_INHERIT if visible else PROCESS_MODE_DISABLED
```

Beispiel: Die Industrie-Barriere im Wald verschwindet mit `show_if_set = false` und `flag = "arena_1_besiegt"`.

## 4. Flashback = eigene Map

Ein Flashback ist einfach eine eigene Map-Szene (z. B. `Szene/Maps/Flashbacks/berliner_mauer.tscn`) mit anderem Look:

- Einen `CanvasModulate` in Sepia (z. B. `Color(0.9, 0.8, 0.6)`) in die Szene legen.
- Am Ende: `GameState.set_flag("flashback_mauer_gesehen")`, Belohnung geben, zurück zur alten Map (Map-Wechsel siehe Karten-Tutorial).
