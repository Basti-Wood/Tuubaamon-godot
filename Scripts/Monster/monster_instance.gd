extends Resource
class_name MonsterInstance

## PLATZHALTER - ein konkretes, gefangenes Monster.
## MonsterData (Resources/Monsters/*.tres) beschreibt die ART (z. B. "Fuego").
## MonsterInstance ist EIN Exemplar davon mit Level, KP, Attacken, Spitzname und Amulett.

@export var species: MonsterData
@export var nickname: String = ""
@export var level: int = 5

# TODO: @export var current_exp: int = 0
# TODO: @export var current_hp: int
# TODO: @export var moves: Array[MoveData] = []     # max. 4
# TODO: @export var move_pp: Array[int] = []
# TODO: @export var status: StatusEffect = null
# TODO: @export var amulet: AmuletData                # das Schmuckstück, in dem das Monster wohnt

func get_display_name() -> String:
	return nickname if nickname != "" else (species.name if species else "???")

func get_max_hp() -> int:
	# TODO: Formel wie Pokémon: ((2 * species.base_hp * level) / 100) + level + 10
	#       plus Bonus aus dem Amulett (amulet.bonus_hp)
	return 1

func get_stat(stat_name: String) -> int:
	# TODO: ((2 * base * level) / 100) + 5, plus Amulett-Bonus. stat_name: "attack", "defense", ...
	return 1

func gain_exp(amount: int) -> void:
	# TODO: current_exp += amount
	# solange current_exp >= exp_for_level(level + 1): level_up()
	pass

func level_up() -> void:
	# TODO: level += 1
	# neue Attacken aus species.level_up_moves für dieses Level anbieten
	# Entwicklung prüfen: species.evolves_into und species.evolution_level
	pass

func to_dict() -> Dictionary:
	# TODO: für den SaveManager: Pfad der Art, Spitzname, Level, KP, Attacken-Pfade, AP, Amulett
	return {}

static func from_dict(data: Dictionary) -> MonsterInstance:
	# TODO: Gegenstück zu to_dict()
	return MonsterInstance.new()
