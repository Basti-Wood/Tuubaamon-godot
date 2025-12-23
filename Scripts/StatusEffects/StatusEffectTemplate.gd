extends Resource
class_name StatusEffect

# =========================
# IDENTIFICATION
# =========================
@export var Name: String
@export_multiline var Description: String

# =========================
# STATUS TYPE
# =========================
enum e_Type {
	PERSISTENT,   # Poison, Burn, Regeneration
	TEMPORARY,    # Sleep, Freeze
	INSTANT       # Confuse trigger, Flinch
}
@export var StatusType: e_Type = e_Type.PERSISTENT

# =========================
# DURATION
# =========================
@export var MaxTurns: int = -1   # -1 = infinite duration
@export var CanStack: bool = false  # Can multiple instances stack?

# =========================
# ACTION MODIFIERS
# =========================
@export_range(0, 100) var BlocksActionChance: int = 0   # Chance to skip turn (paralysis, freeze)
@export var AttackModifier: float = 1.0   # Multiplier to Attack
@export var DefenseModifier: float = 1.0  # Multiplier to Defense
@export var SpeedModifier: float = 1.0    # Multiplier to Speed

# =========================
# DAMAGE / HEALING
# =========================
@export var DamagePerTurnPercent: float = 0.0  # e.g., poison/burn: 0.1 = 10% of max HP per turn
@export var HealPerTurnPercent: float = 0.0    # For regeneration effects

# =========================
# SPECIAL FLAGS (Optional)
# =========================
@export var PreventsStatus: bool = false   # e.g., Safeguard
@export var RemovesOnBattleEnd: bool = true
