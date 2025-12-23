extends Node
class_name DebugBattleManager

## Debug Battle Manager - Allows testing all resources in a controlled battle environment

# =========================
# SIGNALS
# =========================

signal setup_completed()
signal battle_log_updated(message: String)
signal player_hp_changed(current: int, max_hp: int)
signal enemy_hp_changed(current: int, max_hp: int)
signal qte_started(qte_type: int, time_window: float)
signal qte_progress_changed(progress: float)
signal qte_ended(success: bool, level: float)
signal turn_changed(is_player_turn: bool)
signal battle_ended(winner: String)
signal action_menu_requested()  # New: Show Fight/Item/Run menu
signal moves_updated()  # New: PP changed, update move buttons
signal items_updated()  # New: Items changed (used/consumed)

# =========================
# RESOURCE PATHS
# =========================

const MONSTERS_PATH = "res://Resources/Monsters/"
const MOVES_PATH = "res://Resources/Moves/"
const ITEMS_PATH = "res://Resources/Items/"
const ABILITIES_PATH = "res://Resources/Abilities/"
const STATUS_PATH = "res://Resources/StatusEffects/"

# =========================
# LOADED RESOURCES
# =========================

var available_monsters: Array = []
var available_moves: Array = []
var available_items: Array = []
var available_abilities: Array = []
var available_status_effects: Array = []

# =========================
# BATTLE STATE
# =========================

var player_monster: Dictionary = {}
var enemy_monster: Dictionary = {}
var player_items: Array = []
var player_move_pp: Dictionary = {}  # Track PP for each move: {move_index: current_pp}
var enemy_move_pp: Dictionary = {}   # Track PP for enemy moves
var is_battle_active: bool = false
var is_player_turn: bool = true
var current_qte_move: MoveData = null
var current_move_index: int = -1  # Track which move is being used

# QTE System
var qte_active: bool = false
var qte_type: int = 0
var qte_time_remaining: float = 0.0
var qte_max_time: float = 1.0
var qte_progress: float = 0.0
var qte_difficulty: int = 3
var qte_button_mash_count: int = 0
var qte_button_mash_required: int = 10
var qte_hold_duration: float = 0.0
var qte_hold_required: float = 1.0
var qte_is_holding: bool = false

# =========================
# INITIALIZATION
# =========================

func _ready() -> void:
	load_all_resources()

func _process(delta: float) -> void:
	if qte_active:
		_process_qte(delta)

## Load all resources from the Resources folder
func load_all_resources() -> void:
	available_monsters = _load_resources_from_folder(MONSTERS_PATH, "MonsterData")
	available_moves = _load_resources_from_folder(MOVES_PATH, "MoveData")
	available_items = _load_resources_from_folder(ITEMS_PATH, "ItemData")
	available_abilities = _load_resources_from_folder(ABILITIES_PATH, "AbilityData")
	available_status_effects = _load_resources_from_folder(STATUS_PATH, "StatusEffect")
	
	_log("Loaded %d monsters, %d moves, %d items, %d abilities, %d status effects" % [
		available_monsters.size(),
		available_moves.size(),
		available_items.size(),
		available_abilities.size(),
		available_status_effects.size()
	])

func _load_resources_from_folder(path: String, type_name: String) -> Array:
	var resources = []
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres") and not file_name.begins_with("1"):
				var resource_path = path + file_name
				var resource = load(resource_path)
				if resource:
					resources.append(resource)
					_log("Loaded: %s" % file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		_log("Could not open folder: %s" % path)
	
	return resources

# =========================
# MONSTER SETUP
# =========================

## Create a battle-ready monster dictionary from MonsterData
func create_battle_monster(data: MonsterData, level: int = 50) -> Dictionary:
	var monster = {
		"data": data,
		"name": data.name,
		"level": level,
		"types": [data.primary_type],
		"max_hp": _calculate_stat(data.base_hp, level),
		"current_hp": 0,
		"attack": _calculate_stat(data.base_attack, level),
		"defense": _calculate_stat(data.base_defense, level),
		"special_attack": _calculate_stat(data.base_special_attack, level),
		"special_defense": _calculate_stat(data.base_special_defense, level),
		"speed": _calculate_stat(data.base_speed, level),
		"attack_stage": 0,
		"defense_stage": 0,
		"special_attack_stage": 0,
		"special_defense_stage": 0,
		"speed_stage": 0,
		"moves": [],
		"status_effects": [],
		"selected_move": null,
		"selected_move_priority": 0
	}
	
	# Add secondary type if present
	if data.secondary_type != MonsterData.e_Type.NONE:
		monster["types"].append(data.secondary_type)
	
	# Set HP
	monster["current_hp"] = monster["max_hp"]
	
	# Get moves available at this level
	for level_move in data.level_up_moves:
		if level_move.level <= level:
			monster["moves"].append(level_move.move)
	
	# Add some default moves if none available
	if monster["moves"].is_empty() and available_moves.size() > 0:
		monster["moves"].append(available_moves[0])
	
	return monster

func _calculate_stat(base: int, level: int) -> int:
	# Simplified stat formula
	return int(((2.0 * base * level) / 100.0) + level + 10)

# =========================
# BATTLE SETUP
# =========================

## Set up the player's monster
func set_player_monster(monster_data: MonsterData, level: int = 50, custom_moves: Array = []) -> void:
	player_monster = create_battle_monster(monster_data, level)
	if not custom_moves.is_empty():
		player_monster["moves"] = custom_moves
	# Initialize PP for all moves
	player_move_pp.clear()
	for i in range(player_monster["moves"].size()):
		var move: MoveData = player_monster["moves"][i]
		player_move_pp[i] = move.MaxPP
	_log("Player selected: %s (Lv.%d)" % [player_monster["name"], level])
	player_hp_changed.emit(player_monster["current_hp"], player_monster["max_hp"])

## Set up the enemy monster
func set_enemy_monster(monster_data: MonsterData, level: int = 50, custom_moves: Array = []) -> void:
	enemy_monster = create_battle_monster(monster_data, level)
	if not custom_moves.is_empty():
		enemy_monster["moves"] = custom_moves
	# Initialize PP for all moves
	enemy_move_pp.clear()
	for i in range(enemy_monster["moves"].size()):
		var move: MoveData = enemy_monster["moves"][i]
		enemy_move_pp[i] = move.MaxPP
	_log("Enemy selected: %s (Lv.%d)" % [enemy_monster["name"], level])
	enemy_hp_changed.emit(enemy_monster["current_hp"], enemy_monster["max_hp"])

## Set player's items
func set_player_items(items: Array) -> void:
	player_items = items
	_log("Player has %d items" % items.size())

## Add custom moves to a monster
func add_move_to_player(move: MoveData) -> void:
	if player_monster.has("moves"):
		player_monster["moves"].append(move)
		_log("Added move: %s to player" % move.MoveName)

func add_move_to_enemy(move: MoveData) -> void:
	if enemy_monster.has("moves"):
		enemy_monster["moves"].append(move)
		_log("Added move: %s to enemy" % move.MoveName)

# =========================
# BATTLE FLOW
# =========================

## Start the battle
func start_battle() -> void:
	if player_monster.is_empty() or enemy_monster.is_empty():
		_log("ERROR: Both player and enemy must be set!")
		return
	
	is_battle_active = true
	is_player_turn = player_monster["speed"] >= enemy_monster["speed"]
	
	_log("=== BATTLE START ===")
	_log("%s vs %s" % [player_monster["name"], enemy_monster["name"]])
	_log("%s goes first!" % (player_monster["name"] if is_player_turn else enemy_monster["name"]))
	
	turn_changed.emit(is_player_turn)
	
	# If player goes first, show action menu; otherwise enemy acts first
	if is_player_turn:
		action_menu_requested.emit()
	else:
		await get_tree().create_timer(0.5).timeout
		_execute_enemy_turn()

## Try to run from battle
func try_run() -> void:
	if not is_battle_active or not is_player_turn:
		return
	
	# Simple run chance based on speed
	var run_chance = float(player_monster["speed"]) / float(enemy_monster["speed"]) * 50.0
	run_chance = clampf(run_chance, 20.0, 90.0)
	
	if randf() * 100.0 < run_chance:
		_log("Got away safely!")
		is_battle_active = false
		battle_ended.emit("run")
	else:
		_log("Can't escape!")
		_after_player_turn()

## Execute a move (player action)
func execute_player_move(move_index: int) -> void:
	if not is_battle_active or not is_player_turn:
		return
	
	if move_index < 0 or move_index >= player_monster["moves"].size():
		_log("Invalid move index!")
		return
	
	# Check PP
	var current_pp = player_move_pp.get(move_index, 0)
	if current_pp <= 0:
		_log("No PP left for this move!")
		return
	
	var move: MoveData = player_monster["moves"][move_index]
	player_monster["selected_move"] = move
	current_move_index = move_index
	
	# Consume PP
	player_move_pp[move_index] = current_pp - 1
	_log("%s uses %s! (PP: %d/%d)" % [player_monster["name"], move.MoveName, player_move_pp[move_index], move.MaxPP])
	moves_updated.emit()
	
	# Check for QTE
	if move.HasQTE and move.QTEType != MoveData.e_QTEType.NONE:
		current_qte_move = move
		_start_qte(move.QTEType, move.QTETimeWindow, move.QTEDifficulty)
	else:
		_execute_move(player_monster, enemy_monster, move, 1.0)
		_after_player_turn()

## Use an item
func use_item(item_index: int) -> void:
	if not is_battle_active or not is_player_turn:
		return
	
	if item_index < 0 or item_index >= player_items.size():
		_log("Invalid item index!")
		return
	
	var item: ItemData = player_items[item_index]
	_log("%s uses %s!" % [player_monster["name"], item.ItemName])
	
	# Apply item effect
	_apply_item_effect(item, player_monster)
	
	# Consume the item if it's consumable
	if item.Consumable:
		player_items.remove_at(item_index)
		_log("%s was consumed. (%d remaining)" % [item.ItemName, player_items.size()])
		items_updated.emit()
	
	_after_player_turn()

func _apply_item_effect(item: ItemData, target: Dictionary) -> void:
	var effect_applied = false
	
	# HP Restoration (flat amount)
	if item.RestoresHP > 0:
		var old_hp = target["current_hp"]
		target["current_hp"] = min(target["max_hp"], target["current_hp"] + item.RestoresHP)
		var healed = target["current_hp"] - old_hp
		_log("%s restored %d HP!" % [target["name"], healed])
		effect_applied = true
	
	# HP Restoration (percentage)
	if item.RestoresHPPercent > 0.0:
		var old_hp = target["current_hp"]
		var heal_amount = int(target["max_hp"] * item.RestoresHPPercent)
		target["current_hp"] = min(target["max_hp"], target["current_hp"] + heal_amount)
		var healed = target["current_hp"] - old_hp
		_log("%s restored %d HP! (%.0f%%)" % [target["name"], healed, item.RestoresHPPercent * 100])
		effect_applied = true
	
	# PP Restoration
	if item.RestoresPP > 0:
		for i in range(player_monster["moves"].size()):
			var move: MoveData = player_monster["moves"][i]
			var old_pp = player_move_pp.get(i, 0)
			player_move_pp[i] = min(move.MaxPP, old_pp + item.RestoresPP)
		_log("Restored %d PP to all moves!" % item.RestoresPP)
		moves_updated.emit()
		effect_applied = true
	
	# Restore all PP
	if item.RestoresAllPP:
		for i in range(player_monster["moves"].size()):
			var move: MoveData = player_monster["moves"][i]
			player_move_pp[i] = move.MaxPP
		_log("Fully restored PP for all moves!")
		moves_updated.emit()
		effect_applied = true
	
	# Stat boosts
	if item.BoostAttack > 0:
		target["attack_stage"] = min(6, target.get("attack_stage", 0) + item.BoostAttack)
		_log("%s's Attack rose by %d stage(s)!" % [target["name"], item.BoostAttack])
		effect_applied = true
	
	if item.BoostDefense > 0:
		target["defense_stage"] = min(6, target.get("defense_stage", 0) + item.BoostDefense)
		_log("%s's Defense rose by %d stage(s)!" % [target["name"], item.BoostDefense])
		effect_applied = true
	
	if item.BoostSpeed > 0:
		target["speed_stage"] = min(6, target.get("speed_stage", 0) + item.BoostSpeed)
		_log("%s's Speed rose by %d stage(s)!" % [target["name"], item.BoostSpeed])
		effect_applied = true
	
	if item.BoostSpecialAttack > 0:
		target["special_attack_stage"] = min(6, target.get("special_attack_stage", 0) + item.BoostSpecialAttack)
		_log("%s's Sp. Attack rose by %d stage(s)!" % [target["name"], item.BoostSpecialAttack])
		effect_applied = true
	
	if item.BoostSpecialDefense > 0:
		target["special_defense_stage"] = min(6, target.get("special_defense_stage", 0) + item.BoostSpecialDefense)
		_log("%s's Sp. Defense rose by %d stage(s)!" % [target["name"], item.BoostSpecialDefense])
		effect_applied = true
	
	# Status curing
	if item.CuresAllStatus and target.has("status_effects"):
		target["status_effects"].clear()
		_log("%s was cured of all status conditions!" % target["name"])
		effect_applied = true
	elif item.CuresStatus and target.has("status_effects") and not item.SpecificStatusCure.is_empty():
		var cured = []
		for status_name in item.SpecificStatusCure:
			for i in range(target["status_effects"].size() - 1, -1, -1):
				if target["status_effects"][i].Name == status_name:
					cured.append(status_name)
					target["status_effects"].remove_at(i)
		if not cured.is_empty():
			_log("%s was cured of %s!" % [target["name"], ", ".join(cured)])
			effect_applied = true
	
	# Update HP display
	if target == player_monster:
		player_hp_changed.emit(target["current_hp"], target["max_hp"])
	else:
		enemy_hp_changed.emit(target["current_hp"], target["max_hp"])
	
	if not effect_applied:
		_log("But nothing happened...")

func _after_player_turn() -> void:
	if _check_battle_end():
		return
	
	is_player_turn = false
	turn_changed.emit(is_player_turn)
	
	# Enemy turn (simple AI)
	await get_tree().create_timer(0.5).timeout
	_execute_enemy_turn()

func _execute_enemy_turn() -> void:
	if not is_battle_active:
		return
	
	# Simple AI: pick a random move that has PP
	if enemy_monster["moves"].is_empty():
		_log("%s has no moves!" % enemy_monster["name"])
		is_player_turn = true
		turn_changed.emit(is_player_turn)
		action_menu_requested.emit()
		return
	
	# Find moves with PP remaining
	var valid_moves: Array = []
	for i in range(enemy_monster["moves"].size()):
		if enemy_move_pp.get(i, 0) > 0:
			valid_moves.append(i)
	
	if valid_moves.is_empty():
		_log("%s has no PP left!" % enemy_monster["name"])
		is_player_turn = true
		turn_changed.emit(is_player_turn)
		action_menu_requested.emit()
		return
	
	var move_index = valid_moves[randi() % valid_moves.size()]
	var move: MoveData = enemy_monster["moves"][move_index]
	
	# Consume PP
	enemy_move_pp[move_index] = enemy_move_pp.get(move_index, 0) - 1
	_log("%s uses %s!" % [enemy_monster["name"], move.MoveName])
	
	# Enemy doesn't use QTE
	_execute_move(enemy_monster, player_monster, move, 1.0)
	
	if _check_battle_end():
		return
	
	is_player_turn = true
	turn_changed.emit(is_player_turn)
	action_menu_requested.emit()  # Show action menu for next turn

# =========================
# MOVE EXECUTION
# =========================

func _execute_move(attacker: Dictionary, defender: Dictionary, move: MoveData, qte_multiplier: float) -> void:
	# Check accuracy
	if randf() * 100.0 > move.Accuracy:
		_log("%s's attack missed!" % attacker["name"])
		return
	
	# Calculate damage
	if move.AttackType == MoveData.e_AttackType.STATUS:
		_log("%s used a status move!" % attacker["name"])
		# Handle status effects
		if move.InflictsStatus and move.StatusEffect:
			_apply_status(defender, move.StatusEffect)
		return
	
	var damage = _calculate_damage(attacker, defender, move, qte_multiplier)
	
	# Apply damage
	defender["current_hp"] = max(0, defender["current_hp"] - damage)
	
	_log("%s dealt %d damage!" % [attacker["name"], damage])
	
	if qte_multiplier > 1.0:
		_log("QTE Bonus: x%.2f" % qte_multiplier)
	elif qte_multiplier < 1.0:
		_log("QTE Penalty: x%.2f" % qte_multiplier)
	
	# Update HP displays
	if defender == enemy_monster:
		enemy_hp_changed.emit(defender["current_hp"], defender["max_hp"])
	else:
		player_hp_changed.emit(defender["current_hp"], defender["max_hp"])
	
	# Check for status infliction
	if move.InflictsStatus and move.StatusEffect:
		if randf() * 100.0 <= move.StatusChance:
			_apply_status(defender, move.StatusEffect)

func _calculate_damage(attacker: Dictionary, defender: Dictionary, move: MoveData, qte_mult: float) -> int:
	var level = attacker["level"]
	var power = move.Damage
	
	var attack_stat: float
	var defense_stat: float
	
	if move.AttackType == MoveData.e_AttackType.PHYSICAL:
		attack_stat = attacker["attack"]
		defense_stat = defender["defense"]
	else:
		attack_stat = attacker["special_attack"]
		defense_stat = defender["special_defense"]
	
	# Base damage formula
	var damage = ((2.0 * level / 5.0 + 2.0) * power * attack_stat / defense_stat) / 50.0 + 2.0
	
	# STAB
	if move.MoveType in attacker["types"]:
		damage *= 1.5
		_log("STAB bonus!")
	
	# Type effectiveness (simplified)
	var effectiveness = _get_type_effectiveness(move.MoveType, defender["types"])
	damage *= effectiveness
	
	if effectiveness > 1.0:
		_log("It's super effective!")
	elif effectiveness < 1.0 and effectiveness > 0:
		_log("It's not very effective...")
	elif effectiveness == 0:
		_log("It has no effect...")
	
	# Random factor
	damage *= randf_range(0.85, 1.0)
	
	# QTE multiplier
	damage *= qte_mult
	
	# Critical hit chance
	if randf() < 0.0625:  # 1/16 chance
		damage *= 1.5
		_log("Critical hit!")
	
	return max(1, int(damage))

func _get_type_effectiveness(move_type: int, defender_types: Array) -> float:
	# Simplified type chart - you can expand this
	# Returns 2.0 for super effective, 0.5 for not effective, 0 for immune
	return 1.0  # Default to neutral

func _apply_status(target: Dictionary, status: StatusEffect) -> void:
	target["status_effects"].append(status)
	_log("%s was afflicted with %s!" % [target["name"], status.Name])

# =========================
# QTE SYSTEM
# =========================

func _start_qte(type: int, time_window: float, difficulty: int) -> void:
	qte_active = true
	qte_type = type
	qte_max_time = time_window
	qte_time_remaining = time_window
	qte_difficulty = difficulty
	qte_progress = 0.0
	qte_button_mash_count = 0
	qte_button_mash_required = 5 + (difficulty * 3)
	qte_hold_duration = 0.0
	qte_hold_required = time_window * 0.7
	qte_is_holding = false
	
	_log("QTE Started! Type: %d, Time: %.1fs" % [type, time_window])
	qte_started.emit(type, time_window)

func _process_qte(delta: float) -> void:
	qte_time_remaining -= delta
	
	if qte_time_remaining <= 0:
		# Time's up - complete with current progress
		_complete_qte_with_progress()
		return
	
	# Process HOLD type
	if qte_type == MoveData.e_QTEType.HOLD and qte_is_holding:
		qte_hold_duration += delta
		qte_progress = clampf(qte_hold_duration / qte_hold_required, 0.0, 1.0)
		qte_progress_changed.emit(qte_progress)
		
		if qte_hold_duration >= qte_hold_required:
			_complete_qte_with_progress()
	
	# Update progress for TIMED_PRESS (show timing bar)
	if qte_type == MoveData.e_QTEType.TIMED_PRESS:
		qte_progress = (qte_max_time - qte_time_remaining) / qte_max_time
		qte_progress_changed.emit(qte_progress)

func qte_input_action() -> void:
	if not qte_active:
		return
	
	match qte_type:
		MoveData.e_QTEType.BUTTON_MASH:
			qte_button_mash_count += 1
			qte_progress = clampf(float(qte_button_mash_count) / float(qte_button_mash_required), 0.0, 1.0)
			qte_progress_changed.emit(qte_progress)
			_log("Mash: %d/%d" % [qte_button_mash_count, qte_button_mash_required])
			
			if qte_button_mash_count >= qte_button_mash_required:
				_complete_qte_with_progress()
		
		MoveData.e_QTEType.TIMED_PRESS:
			# For timed press, pressing sets progress based on how close to center (0.5) you are
			# Perfect timing at 50% = 1.0 progress, pressing at edges = lower progress
			var current_position = (qte_max_time - qte_time_remaining) / qte_max_time
			var distance_from_center = abs(current_position - 0.5) * 2.0  # 0 at center, 1 at edges
			qte_progress = 1.0 - distance_from_center  # 1.0 at center, 0 at edges
			qte_progress = clampf(qte_progress, 0.0, 1.0)
			_complete_qte_with_progress()

func qte_hold_start() -> void:
	if qte_active and qte_type == MoveData.e_QTEType.HOLD:
		qte_is_holding = true

func qte_hold_end() -> void:
	if qte_active and qte_type == MoveData.e_QTEType.HOLD:
		qte_is_holding = false
		# When releasing hold, complete with current progress
		_complete_qte_with_progress()

## Complete QTE based on current progress - closer to full bar = better multiplier
func _complete_qte_with_progress() -> void:
	qte_active = false
	
	# Calculate multiplier based on progress (0.0 to 1.0)
	# Interpolate between failure multiplier and success multiplier based on progress
	var fail_mult = current_qte_move.QTEFailureMultiplier
	var success_mult = current_qte_move.QTESuccessMultiplier
	
	# Linear interpolation: at 0% progress = fail_mult, at 100% progress = success_mult
	var qte_multiplier = lerp(fail_mult, success_mult, qte_progress)
	
	# Determine result tier for logging
	var result_text: String
	if qte_progress >= 0.9:
		result_text = "PERFECT"
	elif qte_progress >= 0.7:
		result_text = "GREAT"
	elif qte_progress >= 0.5:
		result_text = "GOOD"
	elif qte_progress >= 0.3:
		result_text = "OK"
	else:
		result_text = "MISS"
	
	_log("QTE %s! (%.0f%% -> x%.2f)" % [result_text, qte_progress * 100, qte_multiplier])
	
	qte_ended.emit(qte_progress >= 0.5, qte_progress)
	
	# Execute the move with QTE result
	_execute_move(player_monster, enemy_monster, current_qte_move, qte_multiplier)
	current_qte_move = null
	
	_after_player_turn()

# =========================
# BATTLE END
# =========================

func _check_battle_end() -> bool:
	if player_monster["current_hp"] <= 0:
		_log("=== %s FAINTED ===" % player_monster["name"])
		_log("=== ENEMY WINS ===")
		is_battle_active = false
		battle_ended.emit("enemy")
		return true
	
	if enemy_monster["current_hp"] <= 0:
		_log("=== %s FAINTED ===" % enemy_monster["name"])
		_log("=== PLAYER WINS ===")
		is_battle_active = false
		battle_ended.emit("player")
		return true
	
	return false

# =========================
# DEBUG HELPERS
# =========================

func _log(message: String) -> void:
	print("[DEBUG BATTLE] " + message)
	battle_log_updated.emit(message)

## Debug: Set HP directly
func debug_set_player_hp(hp: int) -> void:
	player_monster["current_hp"] = clamp(hp, 0, player_monster["max_hp"])
	player_hp_changed.emit(player_monster["current_hp"], player_monster["max_hp"])

func debug_set_enemy_hp(hp: int) -> void:
	enemy_monster["current_hp"] = clamp(hp, 0, enemy_monster["max_hp"])
	enemy_hp_changed.emit(enemy_monster["current_hp"], enemy_monster["max_hp"])

## Debug: Apply status
func debug_apply_status_to_player(status: StatusEffect) -> void:
	_apply_status(player_monster, status)

func debug_apply_status_to_enemy(status: StatusEffect) -> void:
	_apply_status(enemy_monster, status)

## Get resource lists for UI
func get_monster_names() -> Array[String]:
	var names: Array[String] = []
	for m in available_monsters:
		names.append(m.name)
	return names

func get_move_names() -> Array[String]:
	var names: Array[String] = []
	for m in available_moves:
		names.append(m.MoveName)
	return names

func get_item_names() -> Array[String]:
	var names: Array[String] = []
	for i in available_items:
		names.append(i.ItemName)
	return names

## Get current PP for a player move
func get_player_move_pp(move_index: int) -> int:
	return player_move_pp.get(move_index, 0)

## Get max PP for a player move
func get_player_move_max_pp(move_index: int) -> int:
	if move_index >= 0 and move_index < player_monster["moves"].size():
		var move: MoveData = player_monster["moves"][move_index]
		return move.MaxPP
	return 0
