extends AudioStreamPlayer

# Ordner mit deinen Musik-Dateien (achte auf Groß-/Kleinschreibung)
const MUSIC_FOLDER := "res://Assets/Audio/"

# Optional: Fallback, falls das Laden fehlschlägt
const FALLBACK_PATH := "res://Assets/Audio/default.ogg"

# Bus-Index für die Musiksteuerung
var bus_index

func _ready() -> void:
	# Lade Bus Layout Datei
	var layout := load("res://default_bus_layout.tres")
	if layout:
		AudioServer.set_bus_layout(layout)

	# Danach den Index abfragen
	bus_index = AudioServer.get_bus_index("Music")


# Interne Play-Funktion: erwartet ein geladenes AudioStream-Resource
func _play_music(musik: AudioStream, vol_db := 0.0) -> void:
	if musik == null:
		push_error("Kein AudioStream übergeben.")
		return

	# Wenn dieselbe Musik schon läuft, nichts tun
	if stream == musik and is_playing():
		return

	# Godot4: Callable für Signal-Operationen
	var finished_cb := Callable(self, "_on_music_finished")

	# saubere Verbindung (erst trennen falls verbunden)
	if is_connected("finished", finished_cb):
		disconnect("finished", finished_cb)
	connect("finished", finished_cb)

	# AudioStream setzen
	stream = musik

	# Sicherstellen, dass wir auf dem "Music"-Bus sind
	bus = "Music"

	# Bus-Volume anpassen (statt local volume_db)
	AudioServer.set_bus_volume_db(bus_index, vol_db)

	play()


# öffentliche Funktion: akzeptiert entweder einen relativen Dateinamen ("song.mp3")
# oder einen vollen res://-Pfad. Parametername vol_db vermeidet Shadowing.
func play_music_level(song_name: String = "Ömers laminet.mp3", vol_db := 0.0) -> void:
	var path := song_name
	# Wenn kein res://-Pfad übergeben wurde, bauen wir ihn aus dem Ordner zusammen
	if not song_name.begins_with("res://"):
		path = MUSIC_FOLDER + song_name

	# Existenz prüfen (hilft schnell herauszufinden, ob Pfad stimmt)
	if not ResourceLoader.exists(path):
		push_error("Audio-Datei existiert nicht (prüfe Pfad & Schreibweise): " + path)
		# optional: versuche Fallback
		if ResourceLoader.exists(FALLBACK_PATH):
			push_warning("Lade Fallback: " + FALLBACK_PATH)
			var fallback_res := load(FALLBACK_PATH)
			if fallback_res and fallback_res is AudioStream:
				_play_music(fallback_res, vol_db)
		return

	# Datei laden
	var res := load(path)
	if res == null:
		push_error("Fehler beim Laden der Resource: " + path)
		return
	if not res is AudioStream:
		push_error("Geladene Resource ist kein AudioStream: " + path + " (Typ: " + str(res.get_class()) + ")")
		return

	_play_music(res, vol_db)


# Loop: wenn Track endet -> neu starten
func _on_music_finished() -> void:
	play()


# öffentliche Funktion: stoppt die aktuelle Musik
func play_music_stop() -> void:
	if is_playing():
		stop()

	# Signalverbindung zum "finished"-Callback trennen
	var finished_cb := Callable(self, "_on_music_finished")
	if is_connected("finished", finished_cb):
		disconnect("finished", finished_cb)

	# Stream-Referenz zurücksetzen
	stream = null
