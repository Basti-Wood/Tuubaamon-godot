extends Resource
class_name MoveData

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

enum e_AttackType {
	PHYSICAL,
	SPECIAL,
	STATUS
}

enum e_Target {
	ENEMY_SINGLE,
	ENEMY_ALL,
	ALLY_SINGLE,
	ALLY_ALL,
	ALL,
	SELF
}

@export var MoveName: String
@export_multiline var Description: String

@export var MoveType: e_Type
@export var AttackType: e_AttackType
@export var Damage: int
@export_range(0, 100) var Accuracy: int = 100
@export var MaxPP: int = 10
@export var Target: e_Target = e_Target.ENEMY_SINGLE
@export_range(-1, 1) var Priority: int = 0

@export var InflictsStatus: bool = false
@export var StatusEffect: Resource
@export_range(0, 100) var StatusChance: int = 0

@export var Contact: bool = true

# =========================
# QUICK TIME EVENT (QTE)
# =========================
@export_group("Quick Time Event")
@export var HasQTE: bool = false

enum e_QTEType {
	NONE,           # No QTE
	BUTTON_MASH,    # Rapidly press button
	TIMED_PRESS,    # Press at the right moment
	SEQUENCE,       # Press buttons in sequence
	HOLD,           # Hold button for duration
	RHYTHM          # Press to the beat
}
@export var QTEType: e_QTEType = e_QTEType.NONE

# QTE difficulty settings
@export_range(0.1, 3.0) var QTETimeWindow: float = 1.0   # Time to complete QTE
@export_range(1, 10) var QTEDifficulty: int = 3          # How hard the QTE is

# QTE rewards
@export_range(1.0, 3.0) var QTESuccessMultiplier: float = 1.5   # Damage/effect multiplier on perfect
@export_range(1.0, 2.0) var QTEPartialMultiplier: float = 1.2   # Multiplier on partial success
@export_range(0.0, 1.0) var QTEFailureMultiplier: float = 0.75  # Multiplier on failure

# =========================
# ADDITIONAL EFFECTS
# =========================
@export_group("Special Effects")
@export var Recoil: float = 0.0          # Percentage of damage dealt to user
@export var Drain: float = 0.0           # Percentage of damage healed to user
@export var Flinch: int = 0              # Chance to make target flinch
@export var CritRateBonus: int = 0       # Additional crit chance

# Stat changes (stages from -6 to +6)
@export var UserAttackChange: int = 0
@export var UserDefenseChange: int = 0
@export var UserSpeedChange: int = 0
@export var TargetAttackChange: int = 0
@export var TargetDefenseChange: int = 0
@export var TargetSpeedChange: int = 0

# Multi-hit moves
@export var IsMultiHit: bool = false
@export var MinHits: int = 1
@export var MaxHits: int = 1

@export_multiline var BattleText: String  # Custom text when move is used
