extends ItemData
class_name AmuletData

## Schmuck/Amulett, in dem Monster gefangen werden (wie bei Huntik).
## Category im Inspector auf CAPTURE stellen.
## Jedes gefangene Monster braucht sein EIGENES Exemplar: amulet.duplicate(),
## sonst wird beim Aufwerten jedes Monster mit demselben Amulett mit aufgewertet.

@export var catch_bonus: float = 1.0          # Multiplikator für die Fangrate
@export var upgrade_level: int = 0
@export var max_upgrade_level: int = 3
@export var upgrade_cost: int = 200           # Geld pro Stufe
@export var bonus_hp: int = 0
@export var bonus_attack: int = 0
@export var bonus_defense: int = 0
@export var bonus_speed: int = 0
@export var model: Texture2D                  # Aussehen des Schmuckstücks

## Eine Stufe aufwerten, kostet Geld. Gibt false zurück, wenn es nicht geht.
func upgrade() -> bool:
	if upgrade_level >= max_upgrade_level or GameState.money < upgrade_cost:
		return false
	GameState.money -= upgrade_cost
	upgrade_level += 1
	bonus_hp += 5
	bonus_attack += 2
	bonus_defense += 2
	bonus_speed += 1
	return true
