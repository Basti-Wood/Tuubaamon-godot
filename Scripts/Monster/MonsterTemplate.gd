extends Resource
class_name MonsterData

# =========================
# ENUMS
# =========================

enum e_Type {
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

enum e_GrowthRate {
	FAST,
	MEDIUM,
	SLOW
}

# =========================
# IDENTITY
# =========================

@export var name: String
@export var monster_id: int
@export_multiline var description: String

# Paper Mario–style: single sprite
@export var sprite: Texture2D = preload("res://Assets/DEBUG/DEBUG_sprite.png")
@export var idle_animation: String
@export var attack_animation: String
@export var hurt_animation: String
@export var defeat_animation: String

@export var sound_cry: AudioStream = preload("res://Assets/DEBUG/DEBUG_sound.mp3")

# =========================
# TYPES
# =========================

# Limit to 1–2 types by convention
@export var primary_type: e_Type = 1
@export var secondary_type: e_Type

# =========================
# BASE STATS
# =========================

@export var base_hp: int = 1
@export var base_attack: int = 1
@export var base_defense: int = 1
@export var base_special_attack: int = 1
@export var base_special_defense: int = 1
@export var base_speed: int = 1


# =========================
# PROGRESSION
# =========================

@export var base_exp_yield: int = 10
@export var growth_rate: e_GrowthRate = e_GrowthRate.MEDIUM
@export_range(0, 100) var catch_rate: float = 100

# =========================
# ABILITIES / TRAITS
# =========================

# Passive effects (simpler than Pokémon abilities)
@export var abilities: Array[AbilityData] = []

# =========================
# MOVES & ATTACKS
# =========================

# Moves learned automatically at levels
# { level : MoveData }
@export var level_up_moves: Array[LevelUpMove]


# =========================
# EVOLUTION
# =========================

@export var evolves_into: MonsterData
@export var evolution_level: int = -1
@export var evolution_item: Resource

# =========================
# DEBUG / NOTES
# =========================

@export_multiline var developer_notes: String
