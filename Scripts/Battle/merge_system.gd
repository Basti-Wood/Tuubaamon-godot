extends Node
class_name MergeSystem

## Merge System - Allows the player to merge with a monster
## The player gains the monster's type(s), moves, and stat bonuses

# =========================
# SIGNALS
# =========================

signal merge_started(monster: MonsterData)
signal merge_ended()
signal merge_turn_expired(turns_remaining: int)

# =========================
# MERGE STATE
# =========================

var is_merged: bool = false
var merged_monster_data: MonsterData = null
var merge_turns_remaining: int = -1  # -1 = unlimited, > 0 = limited turns
var max_merge_turns: int = 10  # Default max merge duration

# Stat bonus multipliers (percentage of monster's base stats added to player)
const MERGE_STAT_BONUS: float = 0.4  # 40% of monster stats

# =========================
# MERGE OPERATIONS
# =========================

## Merge player with a monster
## Returns the merged battle data dictionary
func merge(player: PlayerData, monster: MonsterData, player_level: int = 1) -> Dictionary:
	if is_merged:
		push_warning("Already merged! Unmerge first.")
		return {}
	
	is_merged = true
	merged_monster_data = monster
	merge_turns_remaining = max_merge_turns
	
	merge_started.emit(monster)
	
	return _create_merged_battler(player, monster, player_level)

## Unmerge the player from the monster
func unmerge() -> void:
	is_merged = false
	merged_monster_data = null
	merge_turns_remaining = -1
	merge_ended.emit()

## Decrement merge turns (call each turn while merged)
func tick_merge_turn() -> bool:
	if not is_merged:
		return false
	
	if merge_turns_remaining > 0:
		merge_turns_remaining -= 1
		merge_turn_expired.emit(merge_turns_remaining)
		
		if merge_turns_remaining <= 0:
			unmerge()
			return false
	
	return true

# =========================
# MERGED BATTLER CREATION
# =========================

## Create a battle-ready dictionary for a merged player
static func _create_merged_battler(player: PlayerData, monster: MonsterData, player_level: int) -> Dictionary:
	var merged = {
		"name": "%s + %s" % [player.player_name, monster.name],
		"is_player_merged": true,
		"player_data": player,
		"monster_data": monster,
		"level": player_level,
		# Types: player is typeless, gains monster types on merge
		"types": _get_merged_types(monster),
		# Stats: player base + monster bonus
		"max_hp": _calculate_merged_stat(player.base_hp, monster.base_hp, player_level),
		"current_hp": 0,
		"attack": _calculate_merged_stat(player.base_attack, monster.base_attack, player_level),
		"defense": _calculate_merged_stat(player.base_defense, monster.base_defense, player_level),
		"special_attack": _calculate_merged_stat(player.base_special_attack, monster.base_special_attack, player_level),
		"special_defense": _calculate_merged_stat(player.base_special_defense, monster.base_special_defense, player_level),
		"speed": _calculate_merged_stat(player.base_speed, monster.base_speed, player_level),
		"attack_stage": 0,
		"defense_stage": 0,
		"special_attack_stage": 0,
		"special_defense_stage": 0,
		"speed_stage": 0,
		"accuracy_stage": 0,
		"evasion_stage": 0,
		"crit_stage": 0,
		# Moves: monster's moves (player can use them)
		"moves": _get_merged_moves(monster, player_level),
		"status_effects": [],
		"selected_move": null,
		"selected_move_priority": 0,
		# Merge-specific
		"merge_turns_remaining": 10,
		"merge_stat_bonus": MERGE_STAT_BONUS
	}
	
	merged["current_hp"] = merged["max_hp"]
	return merged

## Calculate a merged stat: player_base + (monster_base * bonus_ratio * level_factor)
static func _calculate_merged_stat(player_base: int, monster_base: int, level: int) -> int:
	var monster_contribution = int(monster_base * MERGE_STAT_BONUS)
	var level_factor = 1.0 + (level - 1) * 0.02  # Slight scaling with level
	return int((player_base + monster_contribution) * level_factor)

## Get types from merged monster
static func _get_merged_types(monster: MonsterData) -> Array:
	var types = [monster.primary_type]
	if monster.secondary_type != Enums.Type.NONE:
		types.append(monster.secondary_type)
	return types

## Get moves available from merged monster at given level
static func _get_merged_moves(monster: MonsterData, player_level: int) -> Array:
	var moves = []
	for level_move in monster.level_up_moves:
		if level_move.level <= player_level:
			moves.append(level_move.move)
	return moves

# =========================
# UNMERGED PLAYER BATTLER
# =========================

## Create a battle-ready dictionary for an unmerged player
static func create_player_battler(player: PlayerData, player_level: int) -> Dictionary:
	var battler = {
		"name": player.player_name,
		"is_player_human": true,
		"player_data": player,
		"level": player_level,
		# Human is TYPELESS - no STAB, normal type effectiveness
		"types": [],
		"max_hp": _calculate_player_stat(player.base_hp, player_level),
		"current_hp": 0,
		"attack": _calculate_player_stat(player.base_attack, player_level),
		"defense": _calculate_player_stat(player.base_defense, player_level),
		"special_attack": _calculate_player_stat(player.base_special_attack, player_level),
		"special_defense": _calculate_player_stat(player.base_special_defense, player_level),
		"speed": _calculate_player_stat(player.base_speed, player_level),
		"attack_stage": 0,
		"defense_stage": 0,
		"special_attack_stage": 0,
		"special_defense_stage": 0,
		"speed_stage": 0,
		"accuracy_stage": 0,
		"evasion_stage": 0,
		"crit_stage": 0,
		# Unmerged player has basic "Struggle"-like attack
		"moves": [_create_player_basic_attack()],
		"status_effects": [],
		"selected_move": null,
		"selected_move_priority": 0
	}
	
	battler["current_hp"] = battler["max_hp"]
	return battler

## Calculate player stat from base
static func _calculate_player_stat(base: int, level: int) -> int:
	return int(((2.0 * base * level) / 100.0) + level + 10)

## Create a basic attack for unmerged player
static func _create_player_basic_attack() -> MoveData:
	var punch = MoveData.new()
	punch.MoveName = "Punch"
	punch.Description = "A basic punch attack."
	punch.MoveType = Enums.Type.NORMAL
	punch.AttackType = Enums.AttackType.PHYSICAL
	punch.Damage = 40
	punch.Accuracy = 100
	punch.MaxPP = 35
	punch.Target = Enums.Target.ENEMY_SINGLE
	punch.HasQTE = true
	punch.QTEType = Enums.QTEType.TIMED_PRESS
	punch.QTETimeWindow = 0.8
	punch.QTEDifficulty = 2
	punch.QTESuccessMultiplier = 1.5
	punch.QTEPartialMultiplier = 1.2
	punch.QTEFailureMultiplier = 0.75
	return punch

# =========================
# UTILITY
# =========================

## Check if a battler is in merged state
static func is_battler_merged(battler: Dictionary) -> bool:
	return battler.get("is_player_merged", false)

## Check if a battler is a human player (not a monster)
static func is_battler_human(battler: Dictionary) -> bool:
	return battler.get("is_player_human", false) or battler.get("is_player_merged", false)

## Get the display name for a battler
static func get_battler_display_name(battler: Dictionary) -> String:
	return battler.get("name", "Unknown")
