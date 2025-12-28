extends Resource
class_name AbilityData

## Ability Template for passive monster effects
## Abilities trigger automatically based on conditions

# =========================
# IDENTIFICATION
# =========================

@export var AbilityName: String
@export_multiline var Description: String
@export var AbilityID: int

# =========================
# ABILITY TRIGGER TYPE
# =========================

@export var TriggerType: Enums.TriggerType = Enums.TriggerType.PASSIVE

# =========================
# TRIGGER CONDITIONS
# =========================

# For HP_THRESHOLD triggers
@export_range(0.0, 1.0) var HPThreshold: float = 0.33  # Activates at 33% HP

# For MOVE_USED triggers
@export var TriggersOnMoveType: Array[int] = []  # Which move types trigger this

# For WEATHER triggers
@export var TriggersInWeather: String = ""  # "sunny", "rain", "sandstorm", "hail"

# For STATUS triggers
@export var TriggersOnStatus: String = ""  # Which status triggers this

# Trigger chance (100 = always)
@export_range(0, 100) var TriggerChance: int = 100

# =========================
# STAT MODIFICATIONS
# =========================

@export_group("Stat Modifiers")
# Permanent stat multipliers (applied while ability is active)
@export var AttackMultiplier: float = 1.0
@export var DefenseMultiplier: float = 1.0
@export var SpecialAttackMultiplier: float = 1.0
@export var SpecialDefenseMultiplier: float = 1.0
@export var SpeedMultiplier: float = 1.0

# Stat stage changes on trigger (temporary)
@export var AttackStageChange: int = 0
@export var DefenseStageChange: int = 0
@export var SpecialAttackStageChange: int = 0
@export var SpecialDefenseStageChange: int = 0
@export var SpeedStageChange: int = 0
@export var AccuracyStageChange: int = 0
@export var EvasionStageChange: int = 0

# =========================
# DAMAGE MODIFICATIONS
# =========================

@export_group("Damage Modifiers")
# Boost specific type moves
@export var BoostMoveType: int = -1  # MoveData.e_Type
@export var MoveTypeBoost: float = 1.0  # 1.5 = 50% boost

# Reduce damage from specific types
@export var ResistMoveType: int = -1
@export var MoveTypeResistance: float = 1.0  # 0.5 = halves damage

# General damage modifiers
@export var OutgoingDamageMultiplier: float = 1.0
@export var IncomingDamageMultiplier: float = 1.0

# Physical/Special modifiers
@export var PhysicalDamageMultiplier: float = 1.0
@export var SpecialDamageMultiplier: float = 1.0
@export var PhysicalResistanceMultiplier: float = 1.0
@export var SpecialResistanceMultiplier: float = 1.0

# =========================
# STATUS IMMUNITY & EFFECTS
# =========================

@export_group("Status Effects")
@export var ImmuneToStatus: Array[String] = []  # List of status names
@export var ImmuneToAllStatus: bool = false

@export var InflictsStatusOnContact: bool = false
@export var ContactStatus: Resource  # StatusEffect resource
@export_range(0, 100) var ContactStatusChance: int = 30

@export var CuresOwnStatus: bool = false  # Automatically cures status
@export var StatusToCure: Array[String] = []  # Which statuses to cure

# =========================
# HEALING & REGENERATION
# =========================

@export_group("Healing")
@export var RegeneratesHP: bool = false
@export var RegenPercentPerTurn: float = 0.0625  # 6.25% per turn

@export var HealOnWeather: bool = false
@export var HealWeatherType: String = ""
@export var HealWeatherPercent: float = 0.0625

@export var LifeStealBonus: float = 0.0  # Additional drain effect

# =========================
# ACCURACY & EVASION
# =========================

@export_group("Accuracy & Evasion")
@export var AccuracyMultiplier: float = 1.0
@export var EvasionMultiplier: float = 1.0

@export var IgnoresAccuracyCheck: bool = false  # Moves never miss
@export var CannotBeMissed: bool = false  # Opponent's moves always hit

# =========================
# WEATHER & TERRAIN
# =========================

@export_group("Weather & Terrain")
@export var CreatesWeatherOnEntry: bool = false
@export var WeatherToCreate: String = ""
@export var WeatherDuration: int = 5

@export var ImmuneToWeatherDamage: bool = false
@export var WeatherImmunityType: String = ""  # "sandstorm", "hail", etc.

# =========================
# PRIORITY & TURN ORDER
# =========================

@export_group("Turn Mechanics")
@export var PriorityBonus: int = 0  # Always move first/last
@export var MovesFirst: bool = false  # Always move first in priority bracket

@export var SkipsTurnChance: int = 0  # Chance to be paralyzed/frozen
@export var CannotBeParalyzed: bool = false
@export var CannotBeFrozen: bool = false

# =========================
# CRITICAL HITS
# =========================

@export_group("Critical Hits")
@export var CritRateBonus: int = 0  # Additional crit stages
@export var AlwaysCrits: bool = false
@export var CannotBeCrit: bool = false

# =========================
# SPECIAL MECHANICS
# =========================

@export_group("Special Effects")
@export var PreventsFlinching: bool = false
@export var PreventsSwitching: bool = false  # Traps opponent

@export var RecoilImmune: bool = false  # Takes no recoil damage
@export var ContactDamagePercent: float = 0.0  # Rough Skin/Iron Barbs

@export var StealStatBoosts: bool = false  # Steals opponent's stat changes

@export var FormChangeOnHP: bool = false  # Changes form at HP threshold
@export var FormChangeThreshold: float = 0.5

@export var PreventItemUse: bool = false  # Prevents opponent from using items

# =========================
# QTE MODIFICATIONS
# =========================

@export_group("QTE Modifiers")
@export var QTETimeBonus: float = 0.0  # Additional time for QTEs
@export var QTEDifficultyReduction: int = 0  # Makes QTEs easier
@export var QTESuccessBonus: float = 0.0  # Additional multiplier on QTE success

# =========================
# ABILITY ACTIVATION TEXT
# =========================

@export_group("Display")
@export var ActivationText: String = ""  # "[Monster]'s [Ability] activated!"
@export var ActivationSound: AudioStream
@export var ShowPopup: bool = true  # Show ability name on activation

# =========================
# HELPER METHODS
# =========================

## Check if ability should trigger
func should_trigger(context: Dictionary) -> bool:
	# Check trigger chance
	if randf() * 100.0 > TriggerChance:
		return false
	
	# Check specific trigger conditions
	match TriggerType:
		Enums.TriggerType.ON_HP_THRESHOLD:
			var hp_ratio = float(context.get("current_hp", 100)) / float(context.get("max_hp", 100))
			return hp_ratio <= HPThreshold
		
		Enums.TriggerType.ON_WEATHER:
			return context.get("weather", "") == TriggersInWeather
		
		Enums.TriggerType.ON_STATUS:
			return context.get("status", "") == TriggersOnStatus
		
		Enums.TriggerType.ON_MOVE_USED:
			return context.get("move_type", -1) in TriggersOnMoveType
	
	return true

## Get damage multiplier for outgoing damage
func get_outgoing_damage_multiplier(move_type: int, is_physical: bool) -> float:
	var multiplier = OutgoingDamageMultiplier
	
	# Type boost
	if move_type == BoostMoveType:
		multiplier *= MoveTypeBoost
	
	# Physical/Special
	if is_physical:
		multiplier *= PhysicalDamageMultiplier
	else:
		multiplier *= SpecialDamageMultiplier
	
	return multiplier

## Get damage multiplier for incoming damage
func get_incoming_damage_multiplier(move_type: int, is_physical: bool) -> float:
	var multiplier = IncomingDamageMultiplier
	
	# Type resistance
	if move_type == ResistMoveType:
		multiplier *= MoveTypeResistance
	
	# Physical/Special resistance
	if is_physical:
		multiplier *= PhysicalResistanceMultiplier
	else:
		multiplier *= SpecialResistanceMultiplier
	
	return multiplier

## Check if immune to a status
func is_immune_to_status(status_name: String) -> bool:
	return ImmuneToAllStatus or status_name in ImmuneToStatus

## Get stat multiplier
func get_stat_multiplier(stat_name: String) -> float:
	match stat_name:
		"attack":
			return AttackMultiplier
		"defense":
			return DefenseMultiplier
		"special_attack":
			return SpecialAttackMultiplier
		"special_defense":
			return SpecialDefenseMultiplier
		"speed":
			return SpeedMultiplier
		_:
			return 1.0

## Get activation message
func get_activation_message(monster_name: String) -> String:
	if ActivationText.is_empty():
		return "%s's %s activated!" % [monster_name, AbilityName]
	return ActivationText.replace("[Monster]", monster_name).replace("[Ability]", AbilityName)
