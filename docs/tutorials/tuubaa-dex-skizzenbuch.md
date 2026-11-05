# Tuubaa-Dex als Skizzenbuch (mit Zeichnen)

Brainstorm: Der Dex ist ein Skizzenbuch (Artbook + Wiki). Jede Seite hat ein Bild von euch, einen kurzen Text und einen Bereich, in dem der Spieler selbst zeichnen kann. Arenaleiter sind Künstler, am Ende malt man ein Bild, das gespeichert wird.

## 1. Gesehen / gefangen merken

In `GameState`:

```gd
var dex_seen := {}    # Monster-Name -> true
var dex_caught := {}
```

Bei jeder Begegnung `GameState.dex_seen[species.name] = true`, beim Fangen `dex_caught`.

## 2. Zeichenfläche

Ein `Control`-Knoten, Größe z. B. 128×128. Malt mit der Maus in ein `Image` und speichert es als PNG.

```gdscript
extends TextureRect

## Einfache Zeichenfläche. Linke Maustaste malt, rechte radiert.

@export var canvas_size := Vector2i(128, 128)
@export var brush_color := Color.BLACK
@export var brush_size := 2

var image: Image

func _ready() -> void:
	image = Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	texture = ImageTexture.create_from_image(image)
	stretch_mode = STRETCH_SCALE
	texture_filter = TEXTURE_FILTER_NEAREST

func _gui_input(event: InputEvent) -> void:
	var paint := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var erase := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	if (event is InputEventMouseMotion or event is InputEventMouseButton) and (paint or erase):
		var p := Vector2i(event.position / size * Vector2(canvas_size))
		var c := brush_color if paint else Color(0, 0, 0, 0)
		image.fill_rect(Rect2i(p - Vector2i.ONE * brush_size / 2, Vector2i.ONE * brush_size), c)
		(texture as ImageTexture).update(image)

func save_to(path: String) -> void:
	image.save_png(path)

func load_from(path: String) -> void:
	if FileAccess.file_exists(path):
		image = Image.load_from_file(path)
		texture = ImageTexture.create_from_image(image)
```

Speichern: `save_to("user://dex/%s.png" % species.name)` (Ordner vorher mit `DirAccess.make_dir_recursive_absolute("user://dex")` anlegen). Das Arenaleiter-Bild genauso: `user://kunst/arena_1.png`.

## 3. Dex-Seite

Aufbau einer Seite (`Control`): links `TextureRect` mit eurem Artwork (`species.sprite`), darunter `Label` mit Text, rechts die Zeichenfläche. Nicht gesehene Monster: Artwork mit `modulate = Color.BLACK` als Silhouette.

Bilderkennung („etwas zeichnen, um etwas freizuschalten“) ist aufwändig. Einfacher Ersatz: Der Spieler zeichnet, ein NPC „bewertet“ es immer positiv, oder man prüft nur, ob genug Pixel gemalt wurden.
