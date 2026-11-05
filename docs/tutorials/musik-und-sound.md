# Musik und Sound (inkl. Morsecode-Ruine)

Es gibt schon den Autoload **AudioPlayer** (`Scripts/Music/audio_player.gd`) mit `play_music_level()`. Brainstorm: Morsecode-Musik in einer Extra-Ruine (wie die Blindenschrift bei den Regis).

## 1. Musik pro Map

Script auf den Wurzelknoten jeder Map:

```gdscript
extends Node2D

@export_file("*.mp3", "*.ogg") var music := ""

func _ready() -> void:
	if music != "":
		AudioPlayer.play_music_level(music)
```

Im Inspector die Datei auswählen. Gleiche Musik läuft beim Map-Wechsel einfach weiter (das prüft der AudioPlayer schon).

Kampfmusik: Vor dem Kampf den alten Track merken (`AudioPlayer.stream`), danach wieder abspielen.

## 2. Soundeffekte

Für kurze Sounds (Treffer, Menü) einen eigenen Autoload **Sfx**:

```gdscript
extends Node

func play(path: String, pitch_variation := 0.0) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.bus = "SFX"   # Bus im Audio-Tab anlegen, falls noch nicht da
	p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
```

Aufruf: `Sfx.play("res://Assets/Audio/SFX/hit.ogg", 0.1)`.

## 3. Morsecode-Ruine

Die Musik spielt eine Nachricht als Piepser. Wer sie entschlüsselt, kennt die Lösung (z. B. die Reihenfolge von Schaltern).

```gdscript
extends AudioStreamPlayer

## Spielt einen Text als Morsecode in Dauerschleife. stream = kurzer Piep-Sound.

@export var message := "OEMER"
@export var unit := 0.15   # Sekunden pro Einheit

const CODE := {
	"A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".", "F": "..-.", "G": "--.",
	"H": "....", "I": "..", "J": ".---", "K": "-.-", "L": ".-..", "M": "--", "N": "-.",
	"O": "---", "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-", "U": "..-",
	"V": "...-", "W": ".--", "X": "-..-", "Y": "-.--", "Z": "--..",
}

func _ready() -> void:
	while is_inside_tree():
		for letter in message.to_upper():
			if letter == " ":
				await get_tree().create_timer(unit * 7).timeout
				continue
			for symbol in CODE.get(letter, ""):
				play()
				await get_tree().create_timer(unit * (1 if symbol == "." else 3)).timeout
				stop()
				await get_tree().create_timer(unit).timeout
			await get_tree().create_timer(unit * 2).timeout
		await get_tree().create_timer(unit * 14).timeout
```

Tipp: Die Ruinen-Hintergrundmusik leiser über den AudioPlayer laufen lassen, den Morse-Piep darüber.
