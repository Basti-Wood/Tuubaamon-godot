# Gebietseffekte, Wetter und Tag/Nacht

Brainstorm: Umgebungseffekte, z. B. in Schneegebieten haben manche Tuubaamon Vorteile, in Wüsten andere (Brandenburg = Wüste, Bayern halb Berg). Der Schadensrechner hat Wetter/Terrain schon vorbereitet. Tag/Nacht wurde nicht besprochen, ist hier nur optional.

## 1. Gebietseffekt pro Map

```gdscript
extends Resource
class_name AreaEffect

@export var name := "Schnee"
@export var boosted_types: Array[int] = []   # Enums.Type, z. B. ICE
@export var weakened_types: Array[int] = []  # z. B. FIRE
@export var boost := 1.2
@export var weaken := 0.8
@export var tint := Color.WHITE              # Farbe für die Overworld

func type_multiplier(move_type: int) -> float:
	if move_type in boosted_types:
		return boost
	if move_type in weakened_types:
		return weaken
	return 1.0
```

An die Map: `@export var area_effect: AreaEffect`, beim Laden `GameState.current_area_effect = area_effect` setzen. Im Schadensrechner am Ende:

```gd
if GameState.current_area_effect:
	damage *= GameState.current_area_effect.type_multiplier(move.type)
```

## 2. Optik: Tönung und Wetter-Partikel

- `CanvasModulate` in die Map, Farbe = `area_effect.tint` (Wüste leicht gelb, Schnee leicht blau).
- Schnee/Sand: `GPUParticles2D` als Kind der Kamera, Emissionsform „Box“ so breit wie der Bildschirm, Richtung nach unten.

## 3. Optional: Tag/Nacht

Ein `CanvasModulate` mit diesem Script färbt die Map nach Uhrzeit. Lampen sind `PointLight2D` und leuchten nachts.

```gdscript
extends CanvasModulate

@export var day_length_sec := 600.0        # 10 Minuten = 1 Tag
@export var gradient: Gradient             # 0 = Mitternacht, 0.5 = Mittag

var time := 0.3                            # 0..1

func _process(delta: float) -> void:
	time = fmod(time + delta / day_length_sec, 1.0)
	if gradient:
		color = gradient.sample(time)

func is_night() -> bool:
	return time < 0.25 or time > 0.8
```

Gradient im Inspector: dunkelblau (0.0), orange (0.25), weiß (0.5), orange (0.75), dunkelblau (1.0). `is_night()` kann Begegnungstabellen umschalten (Nacht-Monster).
