extends Resource
class_name ItemData

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
	FAIRY
}

enum e_Target {
	ENEMY_SINGLE,
	ENEMY_ALL,
	ALLY_SINGLE,
	ALLY_ALL,
	ALL,
	SELF
}

enum e_ItemCategory {
	CONSUMABLE,      # Potions, berries (used in battle)
	BATTLE_ITEM,     # X Attack, X Defense, etc.
	CAPTURE,         # Balls for catching monsters
	EVOLUTION,       # Evolution stones, items
	KEY_ITEM,        # Story/quest items
	HELD_ITEM        # Items monsters can hold
}

enum e_UseContext {
	BATTLE,          # Can be used in battle
	OVERWORLD,       # Can be used outside battle
	BOTH             # Can be used anywhere
}

# =========================
# IDENTIFICATION
# =========================

@export var ItemName: String
@export var ItemID: int
@export_multiline var Description: String
@export var Icon: Texture2D
@export var Category: e_ItemCategory = e_ItemCategory.CONSUMABLE
@export var UseContext: e_UseContext = e_UseContext.BOTH

# =========================
# USAGE
# =========================

@export var Consumable: bool = true
@export var Target: e_Target = e_Target.ALLY_SINGLE
@export var MaxStack: int = 99
@export var BuyPrice: int = 100
@export var SellPrice: int = 50

# =========================
# EFFECTS
# =========================

# HP/PP Restoration
@export var RestoresHP: int = 0
@export var RestoresHPPercent: float = 0.0  # 0.0 to 1.0
@export var RestoresPP: int = 0
@export var RestoresAllPP: bool = false

# Status Effects
@export var CuresStatus: bool = false
@export var CuresAllStatus: bool = false
@export var SpecificStatusCure: Array[String] = []  # Names of specific statuses to cure

@export var RevivesMonster: bool = false
@export var ReviveHPPercent: float = 0.5

# Stat Boosts (temporary in battle)
@export var BoostAttack: int = 0        # Stages +1 to +6
@export var BoostDefense: int = 0
@export var BoostSpecialAttack: int = 0
@export var BoostSpecialDefense: int = 0
@export var BoostSpeed: int = 0
@export var BoostAccuracy: int = 0
@export var BoostEvasion: int = 0

# Capture mechanics
@export var CaptureRateBonus: float = 1.0  # Multiplier for capture (e.g., 2.0 = 2x easier)

# Evolution
@export var TriggersEvolution: bool = false
@export var EvolutionTypes: Array[e_Type] = []  # Which types can evolve with this

# Held Item Effects
@export var HeldItemEffect: String = ""  # Description of passive effect when held
@export var HeldDamageBonus: float = 1.0    # Damage multiplier when held
@export var HeldTypeBoost: e_Type = e_Type.NONE  # Boosts moves of this type

# =========================
# BATTLE TEXT
# =========================

@export_multiline var UseText: String = ""  # Text displayed when used
@export var UseSound: AudioStream

# =========================
# SPECIAL FLAGS
# =========================

@export var OneTimeUse: bool = false  # For key items
@export var Tradeable: bool = true
@export var Droppable: bool = true
