extends Node
class_name TypeChart

## Type effectiveness system for Pokémon-style combat
## Returns damage multipliers based on attacking type vs defending type

# =========================
# ENUMS
# =========================

enum Type {
	NONE,
	NORMAL,
	FIRE,
	WATER,
	ELECTRIC,
	GRASS,
	ICE,
	FIGHTING,
	POISON,
	GROUND,
	FLYING,
	PSYCHIC,
	BUG,
	ROCK,
	GHOST,
	DRAGON,
	DARK,
	STEEL,
	FAIRY,
}

# =========================
# TYPE CHART DATA
# =========================

# Format: [attacking_type][defending_type] = multiplier
# 2.0 = super effective, 0.5 = not very effective, 0.0 = no effect

const TYPE_EFFECTIVENESS = {
	Type.NORMAL: {
		Type.ROCK: 0.5,
		Type.GHOST: 0.0,
		Type.STEEL: 0.5,
	},
	Type.FIRE: {
		Type.FIRE: 0.5,
		Type.WATER: 0.5,
		Type.GRASS: 2.0,
		Type.ICE: 2.0,
		Type.BUG: 2.0,
		Type.ROCK: 0.5,
		Type.DRAGON: 0.5,
		Type.STEEL: 2.0,
	},
	Type.WATER: {
		Type.FIRE: 2.0,
		Type.WATER: 0.5,
		Type.GRASS: 0.5,
		Type.GROUND: 2.0,
		Type.ROCK: 2.0,
		Type.DRAGON: 0.5,
	},
	Type.ELECTRIC: {
		Type.WATER: 2.0,
		Type.ELECTRIC: 0.5,
		Type.GRASS: 0.5,
		Type.GROUND: 0.0,
		Type.FLYING: 2.0,
		Type.DRAGON: 0.5,
	},
	Type.GRASS: {
		Type.FIRE: 0.5,
		Type.WATER: 2.0,
		Type.GRASS: 0.5,
		Type.POISON: 0.5,
		Type.GROUND: 2.0,
		Type.FLYING: 0.5,
		Type.BUG: 0.5,
		Type.ROCK: 2.0,
		Type.DRAGON: 0.5,
		Type.STEEL: 0.5,
	},
	Type.ICE: {
		Type.FIRE: 0.5,
		Type.WATER: 0.5,
		Type.GRASS: 2.0,
		Type.ICE: 0.5,
		Type.GROUND: 2.0,
		Type.FLYING: 2.0,
		Type.DRAGON: 2.0,
		Type.STEEL: 0.5,
	},
	Type.FIGHTING: {
		Type.NORMAL: 2.0,
		Type.ICE: 2.0,
		Type.POISON: 0.5,
		Type.FLYING: 0.5,
		Type.PSYCHIC: 0.5,
		Type.BUG: 0.5,
		Type.ROCK: 2.0,
		Type.GHOST: 0.0,
		Type.DARK: 2.0,
		Type.STEEL: 2.0,
		Type.FAIRY: 0.5,
	},
	Type.POISON: {
		Type.GRASS: 2.0,
		Type.POISON: 0.5,
		Type.GROUND: 0.5,
		Type.ROCK: 0.5,
		Type.GHOST: 0.5,
		Type.STEEL: 0.0,
		Type.FAIRY: 2.0,
	},
	Type.GROUND: {
		Type.FIRE: 2.0,
		Type.ELECTRIC: 2.0,
		Type.GRASS: 0.5,
		Type.POISON: 2.0,
		Type.FLYING: 0.0,
		Type.BUG: 0.5,
		Type.ROCK: 2.0,
		Type.STEEL: 2.0,
	},
	Type.FLYING: {
		Type.ELECTRIC: 0.5,
		Type.GRASS: 2.0,
		Type.FIGHTING: 2.0,
		Type.BUG: 2.0,
		Type.ROCK: 0.5,
		Type.STEEL: 0.5,
	},
	Type.PSYCHIC: {
		Type.FIGHTING: 2.0,
		Type.POISON: 2.0,
		Type.PSYCHIC: 0.5,
		Type.DARK: 0.0,
		Type.STEEL: 0.5,
	},
	Type.BUG: {
		Type.FIRE: 0.5,
		Type.GRASS: 2.0,
		Type.FIGHTING: 0.5,
		Type.POISON: 0.5,
		Type.FLYING: 0.5,
		Type.PSYCHIC: 2.0,
		Type.GHOST: 0.5,
		Type.DARK: 2.0,
		Type.STEEL: 0.5,
		Type.FAIRY: 0.5,
	},
	Type.ROCK: {
		Type.FIRE: 2.0,
		Type.ICE: 2.0,
		Type.FIGHTING: 0.5,
		Type.GROUND: 0.5,
		Type.FLYING: 2.0,
		Type.BUG: 2.0,
		Type.STEEL: 0.5,
	},
	Type.GHOST: {
		Type.NORMAL: 0.0,
		Type.PSYCHIC: 2.0,
		Type.GHOST: 2.0,
		Type.DARK: 0.5,
	},
	Type.DRAGON: {
		Type.DRAGON: 2.0,
		Type.STEEL: 0.5,
		Type.FAIRY: 0.0,
	},
	Type.DARK: {
		Type.FIGHTING: 0.5,
		Type.PSYCHIC: 2.0,
		Type.GHOST: 2.0,
		Type.DARK: 0.5,
		Type.FAIRY: 0.5,
	},
	Type.STEEL: {
		Type.FIRE: 0.5,
		Type.WATER: 0.5,
		Type.ELECTRIC: 0.5,
		Type.ICE: 2.0,
		Type.ROCK: 2.0,
		Type.STEEL: 0.5,
		Type.FAIRY: 2.0,
	},
	Type.FAIRY: {
		Type.FIRE: 0.5,
		Type.FIGHTING: 2.0,
		Type.POISON: 0.5,
		Type.DRAGON: 2.0,
		Type.DARK: 2.0,
		Type.STEEL: 0.5,
	},
}

# =========================
# TYPE EFFECTIVENESS CALCULATION
# =========================

## Get the type effectiveness multiplier
## attack_type: The type of the attacking move
## defend_types: Array of defender's types (1 or 2 types)
static func get_effectiveness(attack_type: Type, defend_types: Array) -> float:
	if attack_type == Type.NONE or defend_types.is_empty():
		return 1.0
	
	var total_multiplier: float = 1.0
	
	# Apply effectiveness against each defending type
	for defend_type in defend_types:
		if defend_type == Type.NONE:
			continue
		
		var multiplier = _get_single_type_effectiveness(attack_type, defend_type)
		total_multiplier *= multiplier
	
	return total_multiplier

## Get effectiveness of one type against another
static func _get_single_type_effectiveness(attack_type: Type, defend_type: Type) -> float:
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
static func is_super_effective(attack_type: Type, defend_types: Array) -> bool:
	return get_effectiveness(attack_type, defend_types) > 1.0

## Check if a move is not very effective
static func is_not_very_effective(attack_type: Type, defend_types: Array) -> bool:
	var effectiveness = get_effectiveness(attack_type, defend_types)
	return effectiveness > 0.0 and effectiveness < 1.0

## Check if a move has no effect
static func is_no_effect(attack_type: Type, defend_types: Array) -> bool:
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
static func type_to_string(type: Type) -> String:
	match type:
		Type.NONE: return "None"
		Type.NORMAL: return "Normal"
		Type.FIRE: return "Fire"
		Type.WATER: return "Water"
		Type.ELECTRIC: return "Electric"
		Type.GRASS: return "Grass"
		Type.ICE: return "Ice"
		Type.FIGHTING: return "Fighting"
		Type.POISON: return "Poison"
		Type.GROUND: return "Ground"
		Type.FLYING: return "Flying"
		Type.PSYCHIC: return "Psychic"
		Type.BUG: return "Bug"
		Type.ROCK: return "Rock"
		Type.GHOST: return "Ghost"
		Type.DRAGON: return "Dragon"
		Type.DARK: return "Dark"
		Type.STEEL: return "Steel"
		Type.FAIRY: return "Fairy"
		_: return "Unknown"

## Get color for type (for UI display)
static func get_type_color(type: Type) -> Color:
	match type:
		Type.NORMAL: return Color(0.66, 0.66, 0.66)
		Type.FIRE: return Color(0.94, 0.5, 0.19)
		Type.WATER: return Color(0.39, 0.56, 0.93)
		Type.ELECTRIC: return Color(0.98, 0.83, 0.19)
		Type.GRASS: return Color(0.47, 0.78, 0.3)
		Type.ICE: return Color(0.6, 0.85, 0.85)
		Type.FIGHTING: return Color(0.75, 0.19, 0.15)
		Type.POISON: return Color(0.64, 0.25, 0.63)
		Type.GROUND: return Color(0.89, 0.75, 0.41)
		Type.FLYING: return Color(0.67, 0.71, 0.91)
		Type.PSYCHIC: return Color(0.98, 0.33, 0.45)
		Type.BUG: return Color(0.65, 0.75, 0.13)
		Type.ROCK: return Color(0.72, 0.63, 0.38)
		Type.GHOST: return Color(0.44, 0.35, 0.6)
		Type.DRAGON: return Color(0.44, 0.22, 0.98)
		Type.DARK: return Color(0.44, 0.35, 0.29)
		Type.STEEL: return Color(0.72, 0.72, 0.82)
		Type.FAIRY: return Color(0.95, 0.52, 0.75)
		_: return Color.WHITE
