extends ItemData
class_name AmuletData

## Schmuck/Amulett, in dem Monster gefangen werden (wie bei Huntik).
## Category im Inspector auf CAPTURE stellen.
## Schmuck kann aufgewertet werden (mehr Werte) und der Spieler kann eigenen Schmuck herstellen.

@export var catch_bonus: float = 1.0          # Multiplikator für die Fangrate
@export var upgrade_level: int = 0
@export var max_upgrade_level: int = 3
@export var bonus_hp: int = 0
@export var bonus_attack: int = 0
@export var bonus_defense: int = 0
@export var bonus_special_attack: int = 0
@export var bonus_special_defense: int = 0
@export var bonus_speed: int = 0
@export var bonus_luck: int = 0                # Glück-Stat
# TODO: @export var model: Texture2D                   # Aussehen des Schmuckstücks

func upgrade(materials: Array) -> bool:
	# TODO: prüfen ob upgrade_level < max_upgrade_level und Materialien reichen
	# Materialien verbrauchen, upgrade_level += 1, Boni erhöhen
	return false
