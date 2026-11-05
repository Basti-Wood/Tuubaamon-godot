extends Resource
class_name MonsterInstance

## PLATZHALTER - ein konkretes, gefangenes Monster.
## MonsterData (Resources/Monsters/*.tres) beschreibt die ART (z. B. "Fuego").
## MonsterInstance ist EIN Exemplar davon mit Level, KP, Attacken, Spitzname und Amulett.

@export var species: MonsterData
@export var nickname: String = ""
@export var level: int = 5

# TODO: @export var current_exp: int = 0
@export var current_hp: int = 1
@export var moves: Array[MoveData] = []     # max. 4
# TODO: @export var move_pp: Array[int] = []
# TODO: @export var status: StatusEffect = null
@export var amulet: AmuletData                # das Schmuckstück, in dem das Monster wohnt

## Neues Exemplar einer Art, z. B. ein wildes Monster. Lernt die letzten 4 Attacken bis zu seinem Level.
static func create(species_data: MonsterData, start_level: int) -> MonsterInstance:
	var monster := MonsterInstance.new()
	monster.species = species_data
	monster.level = start_level
	for entry in species_data.level_up_moves:
		if entry and entry.move and entry.level <= start_level:
			monster.moves.append(entry.move)
	while monster.moves.size() > 4:
		monster.moves.pop_front()
	monster.current_hp = monster.get_max_hp()
	return monster

func is_fainted() -> bool:
	return current_hp <= 0

func get_display_name() -> String:
	return nickname if nickname != "" else (species.name if species else "???")

func get_max_hp() -> int:
	return DamageCalculator.calculate_max_hp(species.base_hp, level) + (amulet.bonus_hp if amulet else 0)

func get_stat(stat_name: String) -> int:
	# stat_name: "attack", "defense", "special_attack", "special_defense", "speed"
	var bonus: int = amulet.get("bonus_" + stat_name) if amulet else 0
	return DamageCalculator.calculate_stat(species.get("base_" + stat_name), level) + bonus

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
