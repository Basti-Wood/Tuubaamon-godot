extends Node
class_name TypeChart

## Type effectiveness system for Pokémon-style combat
## Returns damage multipliers based on attacking type vs defending type

# =========================
# TYPE CHART DATA
# =========================

# Format: [attacking_type][defending_type] = multiplier
# 2.0 = super effective, 0.5 = not very effective, 0.0 = no effect

const TYPE_EFFECTIVENESS = {
	Enums.Type.NORMAL: {
		Enums.Type.ROCK: 0.5,
		Enums.Type.GHOST: 0.0,
		Enums.Type.STEEL: 0.5,
	},
	Enums.Type.FIRE: {
		Enums.Type.FIRE: 0.5,
		Enums.Type.WATER: 0.5,
		Enums.Type.GRASS: 2.0,
		Enums.Type.ICE: 2.0,
		Enums.Type.BUG: 2.0,
		Enums.Type.ROCK: 0.5,
		Enums.Type.DRAGON: 0.5,
		Enums.Type.STEEL: 2.0,
	},
	Enums.Type.WATER: {
		Enums.Type.FIRE: 2.0,
		Enums.Type.WATER: 0.5,
		Enums.Type.GRASS: 0.5,
		Enums.Type.GROUND: 2.0,
		Enums.Type.ROCK: 2.0,
		Enums.Type.DRAGON: 0.5,
	},
	Enums.Type.ELECTRIC: {
		Enums.Type.WATER: 2.0,
		Enums.Type.ELECTRIC: 0.5,
		Enums.Type.GRASS: 0.5,
		Enums.Type.GROUND: 0.0,
		Enums.Type.FLYING: 2.0,
		Enums.Type.DRAGON: 0.5,
	},
	Enums.Type.GRASS: {
		Enums.Type.FIRE: 0.5,
		Enums.Type.WATER: 2.0,
		Enums.Type.GRASS: 0.5,
		Enums.Type.POISON: 0.5,
		Enums.Type.GROUND: 2.0,
		Enums.Type.FLYING: 0.5,
		Enums.Type.BUG: 0.5,
		Enums.Type.ROCK: 2.0,
		Enums.Type.DRAGON: 0.5,
		Enums.Type.STEEL: 0.5,
	},
	Enums.Type.ICE: {
		Enums.Type.FIRE: 0.5,
		Enums.Type.WATER: 0.5,
		Enums.Type.GRASS: 2.0,
		Enums.Type.ICE: 0.5,
		Enums.Type.GROUND: 2.0,
		Enums.Type.FLYING: 2.0,
		Enums.Type.DRAGON: 2.0,
		Enums.Type.STEEL: 0.5,
	},
	Enums.Type.FIGHTING: {
		Enums.Type.NORMAL: 2.0,
		Enums.Type.ICE: 2.0,
		Enums.Type.POISON: 0.5,
		Enums.Type.FLYING: 0.5,
		Enums.Type.PSYCHIC: 0.5,
		Enums.Type.BUG: 0.5,
		Enums.Type.ROCK: 2.0,
		Enums.Type.GHOST: 0.0,
		Enums.Type.DARK: 2.0,
		Enums.Type.STEEL: 2.0,
		Enums.Type.FAIRY: 0.5,
	},
	Enums.Type.POISON: {
		Enums.Type.GRASS: 2.0,
		Enums.Type.POISON: 0.5,
		Enums.Type.GROUND: 0.5,
		Enums.Type.ROCK: 0.5,
		Enums.Type.GHOST: 0.5,
		Enums.Type.STEEL: 0.0,
		Enums.Type.FAIRY: 2.0,
	},
	Enums.Type.GROUND: {
		Enums.Type.FIRE: 2.0,
		Enums.Type.ELECTRIC: 2.0,
		Enums.Type.GRASS: 0.5,
		Enums.Type.POISON: 2.0,
		Enums.Type.FLYING: 0.0,
		Enums.Type.BUG: 0.5,
		Enums.Type.ROCK: 2.0,
		Enums.Type.STEEL: 2.0,
	},
	Enums.Type.FLYING: {
		Enums.Type.ELECTRIC: 0.5,
		Enums.Type.GRASS: 2.0,
		Enums.Type.FIGHTING: 2.0,
		Enums.Type.BUG: 2.0,
		Enums.Type.ROCK: 0.5,
		Enums.Type.STEEL: 0.5,
	},
	Enums.Type.PSYCHIC: {
		Enums.Type.FIGHTING: 2.0,
		Enums.Type.POISON: 2.0,
		Enums.Type.PSYCHIC: 0.5,
		Enums.Type.DARK: 0.0,
		Enums.Type.STEEL: 0.5,
	},
	Enums.Type.BUG: {
		Enums.Type.FIRE: 0.5,
		Enums.Type.GRASS: 2.0,
		Enums.Type.FIGHTING: 0.5,
		Enums.Type.POISON: 0.5,
		Enums.Type.FLYING: 0.5,
		Enums.Type.PSYCHIC: 2.0,
		Enums.Type.GHOST: 0.5,
		Enums.Type.DARK: 2.0,
		Enums.Type.STEEL: 0.5,
		Enums.Type.FAIRY: 0.5,
	},
	Enums.Type.ROCK: {
		Enums.Type.FIRE: 2.0,
		Enums.Type.ICE: 2.0,
		Enums.Type.FIGHTING: 0.5,
		Enums.Type.GROUND: 0.5,
		Enums.Type.FLYING: 2.0,
		Enums.Type.BUG: 2.0,
		Enums.Type.STEEL: 0.5,
	},
	Enums.Type.GHOST: {
		Enums.Type.NORMAL: 0.0,
		Enums.Type.PSYCHIC: 2.0,
		Enums.Type.GHOST: 2.0,
		Enums.Type.DARK: 0.5,
	},
	Enums.Type.DRAGON: {
		Enums.Type.DRAGON: 2.0,
		Enums.Type.STEEL: 0.5,
		Enums.Type.FAIRY: 0.0,
	},
	Enums.Type.DARK: {
		Enums.Type.FIGHTING: 0.5,
		Enums.Type.PSYCHIC: 2.0,
		Enums.Type.GHOST: 2.0,
		Enums.Type.DARK: 0.5,
		Enums.Type.FAIRY: 0.5,
	},
	Enums.Type.STEEL: {
		Enums.Type.FIRE: 0.5,
		Enums.Type.WATER: 0.5,
		Enums.Type.ELECTRIC: 0.5,
		Enums.Type.ICE: 2.0,
		Enums.Type.ROCK: 2.0,
		Enums.Type.STEEL: 0.5,
		Enums.Type.FAIRY: 2.0,
	},
	Enums.Type.FAIRY: {
		Enums.Type.FIRE: 0.5,
		Enums.Type.FIGHTING: 2.0,
		Enums.Type.POISON: 0.5,
		Enums.Type.DRAGON: 2.0,
		Enums.Type.DARK: 2.0,
		Enums.Type.STEEL: 0.5,
	},
}

# =========================
# TYPE EFFECTIVENESS CALCULATION
# =========================

## Get the type effectiveness multiplier
## attack_type: The type of the attacking move
## defend_types: Array of defender's types (1 or 2 types)
static func get_effectiveness(attack_type: Enums.Type, defend_types: Array) -> float:
	if attack_type == Enums.Type.NONE or defend_types.is_empty():
		return 1.0
	
	var total_multiplier: float = 1.0
	
	# Apply effectiveness against each defending type
	for defend_type in defend_types:
		if defend_type == Enums.Type.NONE:
			continue
		
		var multiplier = _get_single_type_effectiveness(attack_type, defend_type)
		total_multiplier *= multiplier
	
	return total_multiplier

## Get effectiveness of one type against another
static func _get_single_type_effectiveness(attack_type: Enums.Type, defend_type: Enums.Type) -> float:
	if not TYPE_EFFECTIVENESS.has(attack_type):
		return 1.0
	
	var attack_chart = TYPE_EFFECTIVENESS[attack_type]
	
	if attack_chart.has(defend_type):
		return attack_chart[defend_type]
	
	return 1.0

# =========================
# HELPER FUNCTIONS
# =========================

## Check if a move is super effective
static func is_super_effective(attack_type: Enums.Type, defend_types: Array) -> bool:
	return get_effectiveness(attack_type, defend_types) > 1.0

## Check if a move is not very effective
static func is_not_very_effective(attack_type: Enums.Type, defend_types: Array) -> bool:
	var effectiveness = get_effectiveness(attack_type, defend_types)
	return effectiveness > 0.0 and effectiveness < 1.0

## Check if a move has no effect
static func is_no_effect(attack_type: Enums.Type, defend_types: Array) -> bool:
	return get_effectiveness(attack_type, defend_types) == 0.0

## Get a text description of the effectiveness
static func get_effectiveness_text(effectiveness: float) -> String:
	if effectiveness == 0.0:
		return "It had no effect..."
	elif effectiveness < 0.5:
		return "It's not very effective..."
	elif effectiveness < 1.0:
		return "It's not very effective..."
	elif effectiveness > 2.0:
		return "It's super effective!"
	elif effectiveness > 1.0:
		return "It's super effective!"
	else:
		return ""

## Convert enum to string
static func type_to_string(type: Enums.Type) -> String:
	match type:
		Enums.Type.NONE: return "None"
		Enums.Type.NORMAL: return "Normal"
		Enums.Type.FIRE: return "Fire"
		Enums.Type.WATER: return "Water"
		Enums.Type.ELECTRIC: return "Electric"
		Enums.Type.GRASS: return "Grass"
		Enums.Type.ICE: return "Ice"
		Enums.Type.FIGHTING: return "Fighting"
		Enums.Type.POISON: return "Poison"
		Enums.Type.GROUND: return "Ground"
		Enums.Type.FLYING: return "Flying"
		Enums.Type.PSYCHIC: return "Psychic"
		Enums.Type.BUG: return "Bug"
		Enums.Type.ROCK: return "Rock"
		Enums.Type.GHOST: return "Ghost"
		Enums.Type.DRAGON: return "Dragon"
		Enums.Type.DARK: return "Dark"
		Enums.Type.STEEL: return "Steel"
		Enums.Type.FAIRY: return "Fairy"
		_: return "Unknown"

## Get color for type (for UI display)
static func get_type_color(type: Enums.Type) -> Color:
	match type:
		Enums.Type.NORMAL: return Color(0.66, 0.66, 0.66)
		Enums.Type.FIRE: return Color(0.94, 0.5, 0.19)
		Enums.Type.WATER: return Color(0.39, 0.56, 0.93)
		Enums.Type.ELECTRIC: return Color(0.98, 0.83, 0.19)
		Enums.Type.GRASS: return Color(0.47, 0.78, 0.3)
		Enums.Type.ICE: return Color(0.6, 0.85, 0.85)
		Enums.Type.FIGHTING: return Color(0.75, 0.19, 0.15)
		Enums.Type.POISON: return Color(0.64, 0.25, 0.63)
		Enums.Type.GROUND: return Color(0.89, 0.75, 0.41)
		Enums.Type.FLYING: return Color(0.67, 0.71, 0.91)
		Enums.Type.PSYCHIC: return Color(0.98, 0.33, 0.45)
		Enums.Type.BUG: return Color(0.65, 0.75, 0.13)
		Enums.Type.ROCK: return Color(0.72, 0.63, 0.38)
		Enums.Type.GHOST: return Color(0.44, 0.35, 0.6)
		Enums.Type.DRAGON: return Color(0.44, 0.22, 0.98)
		Enums.Type.DARK: return Color(0.44, 0.35, 0.29)
		Enums.Type.STEEL: return Color(0.72, 0.72, 0.82)
		Enums.Type.FAIRY: return Color(0.95, 0.52, 0.75)
		_: return Color.WHITE
