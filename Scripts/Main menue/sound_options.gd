extends Control

## Lautstärke-Einstellungen. Speichert über den ConfigManager.

@onready var master_slider = $VBoxContainer/Master
@onready var sound_slider = $VBoxContainer/Music
@onready var sfx_slider = $VBoxContainer/SFX

func _ready() -> void:
	if ConfigManager.current_settings.is_empty():
		ConfigManager.settings_loaded.connect(_load_saved_volumes)
	else:
		_load_saved_volumes()

func _load_saved_volumes():
	# Ohne Signal setzen, sonst wird beim Öffnen direkt wieder gespeichert
	master_slider.set_value_no_signal(ConfigManager.get_master_volume_percent())
	sound_slider.set_value_no_signal(ConfigManager.get_music_volume_percent())
	sfx_slider.set_value_no_signal(ConfigManager.get_sfx_volume_percent())

func _on_master_value_changed(value: float) -> void:
	ConfigManager.set_master_volume_percent(value)

func _on_sound_value_changed(value: float) -> void:
	ConfigManager.set_music_volume_percent(value)

func _on_sfx_value_changed(value: float) -> void:
	ConfigManager.set_sfx_volume_percent(value)

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/main menue/Optionen_menue.tscn")
