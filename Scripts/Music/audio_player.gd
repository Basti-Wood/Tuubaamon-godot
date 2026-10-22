extends AudioStreamPlayer

## Musik-Player (Autoload "AudioPlayer"). Spielt einen Track in Dauerschleife auf dem "Music"-Bus.

const MUSIC_FOLDER := "res://Assets/Audio/"

func _ready() -> void:
	var layout := load("res://default_bus_layout.tres")
	if layout:
		AudioServer.set_bus_layout(layout)
	bus = "Music"
	finished.connect(_on_music_finished)

## Spielt einen Track. Akzeptiert einen Dateinamen aus Assets/Audio ("song.mp3")
## oder einen vollen res://-Pfad.
func play_music_level(song_name: String = "Ömers laminet.mp3", vol_db := 0.0) -> void:
	var path := song_name if song_name.begins_with("res://") else MUSIC_FOLDER + song_name

	if not ResourceLoader.exists(path):
		push_error("Audio-Datei existiert nicht (prüfe Pfad & Schreibweise): " + path)
		return

	var music = load(path)
	if not music is AudioStream:
		push_error("Geladene Resource ist kein AudioStream: " + path)
		return

	# Wenn dieselbe Musik schon läuft, nichts tun
	if stream == music and playing:
		return

	stream = music
	# Nur die Lautstärke dieses Players, die Bus-Lautstärke gehört dem Optionsmenü
	volume_db = vol_db
	play()

func play_music_stop() -> void:
	stop()
	stream = null

# Dauerschleife: wenn der Track endet, neu starten
func _on_music_finished() -> void:
	if stream:
		play()
