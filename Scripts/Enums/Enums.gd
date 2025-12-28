extends Node
class_name Enums

## Centralized Enums for the Tuubaamon project
## This file contains all shared enums used across different systems
## Changing an enum here will automatically update all files that reference it

# =========================
# TYPE ENUMS
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
# ATTACK/MOVE ENUMS
# =========================

enum AttackType {
	PHYSICAL,
	SPECIAL,
	STATUS
}

enum Target {
	ENEMY_SINGLE,
	ENEMY_ALL,
	ALLY_SINGLE,
	ALLY_ALL,
	ALL,
	SELF
}

# =========================
# QUICK TIME EVENT (QTE) ENUMS
# =========================

enum QTEType {
	NONE,           # No QTE
	BUTTON_MASH,    # Rapidly press button
	TIMED_PRESS,    # Press at the right moment
	SEQUENCE,       # Press buttons in sequence
	HOLD,           # Hold button for duration
	RHYTHM          # Press to the beat
}

enum QTEResult {
	FAILURE,   # 0.0 - 0.3
	PARTIAL,   # 0.3 - 0.8
	SUCCESS,   # 0.8 - 1.0
	PERFECT    # Exactly 1.0
}

# =========================
# MONSTER ENUMS
# =========================

enum GrowthRate {
	FAST,
	MEDIUM,
	SLOW
}

# =========================
# ITEM ENUMS
# =========================

enum ItemCategory {
	CONSUMABLE,      # Potions, berries (used in battle)
	BATTLE_ITEM,     # X Attack, X Defense, etc.
	CAPTURE,         # Balls for catching monsters
	EVOLUTION,       # Evolution stones, items
	KEY_ITEM,        # Story/quest items
	HELD_ITEM        # Items monsters can hold
}

enum UseContext {
	BATTLE,          # Can be used in battle
	OVERWORLD,       # Can be used outside battle
	BOTH             # Can be used anywhere
}

# =========================
# ABILITY ENUMS
# =========================

enum TriggerType {
	PASSIVE,           # Always active
	ON_BATTLE_START,   # Triggers when entering battle
	ON_SWITCH_IN,      # Triggers when switching in
	ON_TAKING_DAMAGE,  # Triggers when hit
	ON_DEALING_DAMAGE, # Triggers when attacking
	ON_TURN_START,     # Triggers at start of turn
	ON_TURN_END,       # Triggers at end of turn
	ON_HP_THRESHOLD,   # Triggers when HP reaches threshold
	ON_STATUS,         # Triggers when getting status condition
	ON_MOVE_USED,      # Triggers when using specific move type
	ON_WEATHER,        # Triggers in specific weather
}

# =========================
# STATUS EFFECT ENUMS
# =========================

enum StatusType {
	PERSISTENT,   # Poison, Burn, Regeneration
	TEMPORARY,    # Sleep, Freeze
	INSTANT       # Confuse trigger, Flinch
}
