extends Node
class_name DamageCalculator

## Damage calculation system for battle
## Integrates stats, types, QTE results, and various modifiers

# =========================
# CALCULATION CONSTANTS
# =========================

const BASE_DAMAGE_MODIFIER: float = 2.0
const LEVEL_MODIFIER: float = 0.4
const CRIT_MULTIPLIER: float = 1.5
const STAB_MULTIPLIER: float = 1.5  # Same Type Attack Bonus
const RANDOM_MIN: float = 0.85
const RANDOM_MAX: float = 1.0

# Stat stage multipliers (-6 to +6)
const STAT_STAGE_MULTIPLIERS = {
	-6: 0.25,
	-5: 0.28,
	-4: 0.33,
	-3: 0.4,
	-2: 0.5,
	-1: 0.66,
	0: 1.0,
	1: 1.5,
	2: 2.0,
	3: 2.5,
	4: 3.0,
	5: 3.5,
	6: 4.0,
}

# =========================
# DAMAGE CALCULATION
# =========================

## Calculate damage from attacker to defender
## Returns dictionary with damage and additional info
static func calculate_damage(
	attacker_data: Dictionary,
	defender_data: Dictionary,
	move: MoveData,
	qte_multiplier: float = 1.0,
	is_critical: bool = false,
	weather_modifier: float = 1.0
) -> Dictionary:
	
	# STATUS moves don't deal damage
	if move.AttackType == MoveData.e_AttackType.STATUS:
		return {
			"damage": 0,
			"is_critical": false,
			"type_effectiveness": 1.0,
			"effectiveness_text": ""
		}
	
	# Base damage from move
	var base_damage = move.Damage
	if base_damage <= 0:
		return {
			"damage": 0,
			"is_critical": false,
			"type_effectiveness": 1.0,
			"effectiveness_text": ""
		}
	
	# Get stats
	var level = attacker_data.get("level", 50)
	var attack_stat: float
	var defense_stat: float
	
	# Determine if physical or special
	if move.AttackType == MoveData.e_AttackType.PHYSICAL:
		attack_stat = attacker_data.get("attack", 50)
		defense_stat = defender_data.get("defense", 50)
	else:  # SPECIAL
		attack_stat = attacker_data.get("special_attack", 50)
		defense_stat = defender_data.get("special_defense", 50)
	
	# Apply stat stages
	var attack_stage = attacker_data.get("attack_stage", 0)
	var defense_stage = defender_data.get("defense_stage", 0)
	attack_stat *= get_stat_stage_multiplier(attack_stage)
	defense_stat *= get_stat_stage_multiplier(defense_stage)
	
	# Calculate base damage
	# Formula: ((2 * Level / 5 + 2) * Power * Attack / Defense) / 50 + 2
	var damage: float = ((2.0 * level / 5.0 + 2.0) * base_damage * attack_stat / defense_stat) / 50.0 + 2.0
	
	# Apply modifiers
	var modifiers: float = 1.0
	
	# Critical hit
	if is_critical:
		modifiers *= CRIT_MULTIPLIER
	
	# STAB (Same Type Attack Bonus)
	var attacker_types = attacker_data.get("types", [])
	if move.MoveType in attacker_types:
		modifiers *= STAB_MULTIPLIER
	
	# Type effectiveness
	var defender_types = defender_data.get("types", [])
	var type_effectiveness = TypeChart.get_effectiveness(move.MoveType, defender_types)
	modifiers *= type_effectiveness
	
	# QTE multiplier
	modifiers *= qte_multiplier
	
	# Weather modifier
	modifiers *= weather_modifier
	
	# Random factor (0.85 to 1.0)
	var random_factor = randf_range(RANDOM_MIN, RANDOM_MAX)
	modifiers *= random_factor
	
	# Apply all modifiers
	damage *= modifiers
	
	# Minimum damage is 1
	damage = max(1.0, floor(damage))
	
	# Get effectiveness text
	var effectiveness_text = TypeChart.get_effectiveness_text(type_effectiveness)
	
	return {
		"damage": int(damage),
		"is_critical": is_critical,
		"type_effectiveness": type_effectiveness,
		"effectiveness_text": effectiveness_text,
		"qte_multiplier": qte_multiplier
	}

# =========================
# CRITICAL HIT CALCULATION
# =========================

## Determine if an attack is a critical hit
static func check_critical_hit(attacker_data: Dictionary, move: MoveData) -> bool:
	# Base crit rate (1/16 = 6.25%)
	var crit_chance: float = 6.25
	
	# Add move's crit bonus
	crit_chance += move.CritRateBonus
	
	# Add attacker's crit stage
	var crit_stage = attacker_data.get("crit_stage", 0)
	match crit_stage:
		1: crit_chance = 12.5
		2: crit_chance = 50.0
		3: crit_chance = 100.0
	
	# Roll for crit
	return randf() * 100.0 < crit_chance

# =========================
# ACCURACY CHECK
# =========================

## Determine if a move hits
static func check_accuracy(
	attacker_data: Dictionary,
	defender_data: Dictionary,
	move: MoveData
) -> bool:
	# Moves with -1 accuracy always hit
	if move.Accuracy < 0:
		return true
	
	# Get base accuracy
	var accuracy: float = move.Accuracy
	
	# Apply accuracy stages
	var accuracy_stage = attacker_data.get("accuracy_stage", 0)
	var evasion_stage = defender_data.get("evasion_stage", 0)
	var net_stage = accuracy_stage - evasion_stage
	
	accuracy *= get_accuracy_stage_multiplier(net_stage)
	
	# Roll for hit
	return randf() * 100.0 < accuracy

## Get accuracy stage multiplier
static func get_accuracy_stage_multiplier(stage: int) -> float:
	stage = clampi(stage, -6, 6)
	
	if stage >= 0:
		return (3.0 + stage) / 3.0
	else:
		return 3.0 / (3.0 - stage)

# =========================
# STAT STAGE FUNCTIONS
# =========================

## Get stat multiplier from stage
static func get_stat_stage_multiplier(stage: int) -> float:
	stage = clampi(stage, -6, 6)
	
	if STAT_STAGE_MULTIPLIERS.has(stage):
		return STAT_STAGE_MULTIPLIERS[stage]
	
	return 1.0

## Modify a stat stage
static func modify_stat_stage(current_stage: int, change: int) -> int:
	var new_stage = current_stage + change
	return clampi(new_stage, -6, 6)

# =========================
# MULTI-HIT CALCULATION
# =========================

## Determine number of hits for multi-hit moves
static func calculate_hit_count(move: MoveData) -> int:
	if not move.IsMultiHit:
		return 1
	
	# Random between min and max hits
	return randi_range(move.MinHits, move.MaxHits)

# =========================
# RECOIL & DRAIN
# =========================

## Calculate recoil damage to attacker
static func calculate_recoil(damage_dealt: int, move: MoveData) -> int:
	if move.Recoil <= 0.0:
		return 0
	
	return max(1, int(damage_dealt * move.Recoil))

## Calculate HP drain/heal for attacker
static func calculate_drain(damage_dealt: int, move: MoveData) -> int:
	if move.Drain <= 0.0:
		return 0
	
	return max(1, int(damage_dealt * move.Drain))

# =========================
# STATUS EFFECT CHECK
# =========================

## Check if a status effect is applied
static func check_status_infliction(move: MoveData) -> bool:
	if not move.InflictsStatus:
		return false
	
	if move.StatusChance <= 0:
		return false
	
	return randf() * 100.0 < move.StatusChance

# =========================
# FLINCH CHECK
# =========================

## Check if target flinches
static func check_flinch(move: MoveData) -> bool:
	if move.Flinch <= 0:
		return false
	
	return randf() * 100.0 < move.Flinch

# =========================
# WEATHER EFFECTS
# =========================

## Get weather modifier for move type
static func get_weather_modifier(weather: String, move_type: int) -> float:
	match weather:
		"sunny":
			if move_type == MoveData.e_Type.FIRE:
				return 1.5
			elif move_type == MoveData.e_Type.WATER:
				return 0.5
		"rain":
			if move_type == MoveData.e_Type.WATER:
				return 1.5
			elif move_type == MoveData.e_Type.FIRE:
				return 0.5
		"sandstorm":
			# Rock types get SpDef boost (handled elsewhere)
			pass
		"hail":
			# Ice types don't take damage (handled elsewhere)
			pass
	
	return 1.0

# =========================
# HELPER FUNCTIONS
# =========================

## Create attacker data dictionary from MonsterData
static func create_battle_data(monster_data: MonsterData, level: int) -> Dictionary:
	return {
		"level": level,
		"types": monster_data.types,
		"attack": calculate_stat(monster_data.base_attack, level),
		"defense": calculate_stat(monster_data.base_defense, level),
		"special_attack": calculate_stat(monster_data.base_special_attack, level),
		"special_defense": calculate_stat(monster_data.base_special_defense, level),
		"speed": calculate_stat(monster_data.base_speed, level),
		"attack_stage": 0,
		"defense_stage": 0,
		"special_attack_stage": 0,
		"special_defense_stage": 0,
		"speed_stage": 0,
		"accuracy_stage": 0,
		"evasion_stage": 0,
		"crit_stage": 0,
	}

## Calculate actual stat from base stat and level
static func calculate_stat(base_stat: int, level: int, iv: int = 15, ev: int = 0) -> int:
	# Simplified stat calculation
	# Formula: ((2 * Base + IV + EV/4) * Level / 100) + 5
	return int(((2 * base_stat + iv + ev / 4) * level / 100.0) + 5)

## Calculate max HP
static func calculate_max_hp(base_hp: int, level: int, iv: int = 15, ev: int = 0) -> int:
	# HP uses a different formula
	# Formula: ((2 * Base + IV + EV/4) * Level / 100) + Level + 10
	return int(((2 * base_hp + iv + ev / 4) * level / 100.0) + level + 10)
