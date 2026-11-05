extends Resource
class_name MonsterInstance

## Ein konkretes, gefangenes Monster.
## MonsterData (Resources/Monsters/*.tres) beschreibt die ART (z. B. "Fuego").
## MonsterInstance ist EIN Exemplar davon mit Level, KP, Attacken, Spitzname und Amulett.

@export var species: MonsterData
@export var nickname: String = ""
@export var level: int = 5

@export var current_exp: int = 0
@export var current_hp: int = -1          # -1 = volle KP beim ersten Aufruf von setup()
@export var moves: Array[MoveData] = []   # max. 4
@export var move_pp: Array[int] = []
# TODO: @export var status: StatusEffect = null
# TODO: @export var amulet: AmuletData                # das Schmuckstück, in dem das Monster wohnt

const MAX_MOVES := 4

## Neues Monster erzeugen, z. B. für einen Wildkampf oder ein Starter-Monster.
static func create(p_species: MonsterData, p_level: int) -> MonsterInstance:
	var mon := MonsterInstance.new()
	mon.species = p_species
	mon.level = p_level
	mon.current_exp = mon.exp_for_level(p_level)
	mon.setup()
	return mon

## Volle KP und die letzten 4 Attacken, die es bis zu seinem Level gelernt hätte.
func setup() -> void:
	if current_hp < 0:
		current_hp = get_max_hp()
	if moves.is_empty():
		for entry in species.level_up_moves:
			if entry and entry.move and entry.level <= level:
				learn_move(entry.move)

func get_display_name() -> String:
	return nickname if nickname != "" else (species.name if species else "???")

func get_max_hp() -> int:
	# TODO: plus Bonus aus dem Amulett (amulet.bonus_hp)
	return (2 * species.base_hp * level) / 100 + level + 10

## stat_name: "attack", "defense", "special_attack", "special_defense", "speed", "luck"
func get_stat(stat_name: String) -> int:
	var base: int = species.get("base_" + stat_name)
	# TODO: plus Amulett-Bonus
	return (2 * base * level) / 100 + 5

## Gesamt-EP, die man für ein Level braucht (wie Pokémon: Level hoch 3).
func exp_for_level(lvl: int) -> int:
	var factor := 1.0
	match species.growth_rate:
		Enums.GrowthRate.FAST: factor = 0.8
		Enums.GrowthRate.SLOW: factor = 1.25
	return int(factor * lvl * lvl * lvl)

func gain_exp(amount: int) -> void:
	current_exp += amount
	while level < 100 and current_exp >= exp_for_level(level + 1):
		level_up()

func level_up() -> void:
	var old_max := get_max_hp()
	level += 1
	current_hp += get_max_hp() - old_max
	for entry in species.level_up_moves:
		if entry and entry.move and entry.level == level:
			learn_move(entry.move)
	if species.evolves_into and species.evolution_level > 0 and level >= species.evolution_level:
		evolve()

## Neue Attacke lernen. Bei 4 Attacken fliegt die älteste raus.
## TODO: später fragen, welche Attacke vergessen werden soll.
func learn_move(move: MoveData) -> void:
	if move in moves:
		return
	if moves.size() >= MAX_MOVES:
		moves.remove_at(0)
		move_pp.remove_at(0)
	moves.append(move)
	move_pp.append(move.MaxPP)

## Entwicklung: Art wechseln, KP-Differenz dazugeben. Level, EP und Attacken bleiben.
func evolve() -> void:
	var old_max := get_max_hp()
	species = species.evolves_into
	current_hp += get_max_hp() - old_max

func to_dict() -> Dictionary:
	# TODO: für den SaveManager: Pfad der Art, Spitzname, Level, KP, Attacken-Pfade, AP, Amulett
	return {}

static func from_dict(data: Dictionary) -> MonsterInstance:
	# TODO: Gegenstück zu to_dict()
	return MonsterInstance.new()
