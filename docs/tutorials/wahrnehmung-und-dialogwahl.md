# Wahrnehmungs-Checks und Dialog-Auswahl

Brainstorm: D&D-ähnliche Checks. Mit guten Werten erkennt man mehr, aber es gibt **immer** auch einen Weg ohne Check. Auf den Thüringen-Inseln muss man „das Richtige sagen“ (Berliner/Pfannkuchen/Krapfen), um ein Item zu bekommen. Francois sagt französische Wörter.

## 1. Spieler-Werte

In `PlayerData` (oder `GameState`):

```gd
var perception := 1   # steigt mit Level oder Items (z. B. Lupe)
var charisma := 1
```

## 2. Untersuchbares Objekt mit Check

```gdscript
extends Area2D

## Objekt, das man untersuchen kann. Bei gutem Wert gibt es einen Extra-Hinweis.

@export_multiline var base_text := "Eine alte Steinplatte."
@export_multiline var check_text := "In der Ecke ist ein Symbol eingeritzt: ein Wolf."
@export var difficulty := 3
@export var found_flag := ""   # wird gesetzt, wenn der Check klappt

func interact(player: Node) -> void:
	var lines: Array[String] = [base_text]
	if roll(player.get("perception") if player.get("perception") != null else 1) >= difficulty:
		lines.append(check_text)
		if found_flag != "":
			GameState.set_flag(found_flag)
	print(lines)   # später: DialogueBox.show_lines(lines)

static func roll(stat: int) -> int:
	return randi_range(1, 6) + stat
```

Damit niemand hängen bleibt: Den Hinweis aus `check_text` zusätzlich irgendwo ohne Check unterbringen (Buch, NPC), nur später oder umständlicher.

## 3. Dialog mit Auswahl

```gdscript
extends VBoxContainer

## Zeigt Antwort-Buttons. Gibt den Index der Wahl zurück.

signal chosen(index: int)

func ask(options: Array[String]) -> int:
	for c in get_children():
		c.queue_free()
	for i in options.size():
		var b := Button.new()
		b.text = options[i]
		b.pressed.connect(func(): chosen.emit(i))
		add_child(b)
	get_child(0).grab_focus.call_deferred()
	var result: int = await chosen
	for c in get_children():
		c.queue_free()
	return result
```

Thüringen-Beispiel im NPC:

```gd
var pick := await $ChoiceBox.ask(["Berliner", "Pfannkuchen", "Krapfen"])
if pick == 1:   # diese Insel sagt Pfannkuchen
	GameState.set_flag("thueringen_item_bekommen")
```

Mit Charisma-Check: eine zusätzliche Option nur anzeigen, wenn `charisma >= 3`.
