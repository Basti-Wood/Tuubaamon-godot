extends Node
class_name DebugBattleManager

## Debug Battle Manager - Allows testing all resources in a controlled battle environment
## Now delegates to QTESystem, DamageCalculator, and TypeChart for core logic

# =========================
# SIGNALS
# =========================

signal battle_log_updated(message: String)
signal player_hp_changed(current: int, max_hp: int)
signal enemy_hp_changed(current: int, max_hp: int)
signal qte_started(qte_type: int, time_window: float)
signal qte_progress_changed(progress: float)
signal qte_ended(success: bool, level: float)
signal turn_changed(is_player_turn: bool)
signal battle_ended(winner: String)
signal action_menu_requested()
signal moves_updated()
signal items_updated()

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
var player_move_pp: Dictionary = {}
var enemy_move_pp: Dictionary = {}
var is_battle_active: bool = false
var is_player_turn: bool = true
var current_qte_move: MoveData = null
var current_move_index: int = -1

# =========================
# CORE SYSTEM REFERENCES
# =========================

var qte_system: QTESystem = null
var damage_calculator = DamageCalculator

# Public QTE state (exposed for UI binding)
var qte_active: bool = false:
	get: return qte_system and qte_system.is_active
var qte_time_remaining: float = 0.0:
	get: return qte_system.qte_time_remaining if qte_system else 0.0

# =========================
# INITIALIZATION
# =========================

func _ready() -> void:
	# Create QTE system
	qte_system = QTESystem.new()
	qte_system.name = "QTESystem"
	add_child(qte_system)
	
	# Connect QTE signals
	qte_system.qte_started.connect(_on_qte_internal_started)
	qte_system.qte_completed.connect(_on_qte_internal_completed)
	qte_system.qte_failed.connect(_on_qte_internal_failed)
	qte_system.qte_progress_updated.connect(_on_qte_internal_progress)
	
	load_all_resources()

# =========================
# QTE SIGNAL FORWARDING
# =========================

func _on_qte_internal_started(qte_type: int) -> void:
	qte_started.emit(qte_type, qte_system.qte_max_time)

func _on_qte_internal_progress(progress: float) -> void:
	qte_progress_changed.emit(progress)

func _on_qte_internal_completed(success_level: float) -> void:
	if not current_qte_move:
		_log("QTE completed but no move pending!")
		return
	
	var qte_mult = qte_system.get_damage_multiplier(current_qte_move)
	
	var result_text: String
	if success_level >= 1.0:
		result_text = "PERFECT"
	elif success_level >= 0.8:
		result_text = "GREAT"
	elif success_level >= 0.5:
		result_text = "GOOD"
	else:
		result_text = "OK"
	
	_log("QTE %s! (%.0f%% -> x%.2f)" % [result_text, success_level * 100, qte_mult])
	qte_ended.emit(true, success_level)
	
	# Execute the move with QTE result
	_execute_move(player_monster, enemy_monster, current_qte_move, qte_mult)
	current_qte_move = null
	_after_player_turn()

func _on_qte_internal_failed() -> void:
	if not current_qte_move:
		_log("QTE failed but no move pending!")
		return
	
	var fail_mult = current_qte_move.QTEFailureMultiplier
	_log("QTE Failed! (x%.2f)" % fail_mult)
	qte_ended.emit(false, 0.0)
	
	_execute_move(player_monster, enemy_monster, current_qte_move, fail_mult)
	current_qte_move = null
	_after_player_turn()

## Public QTE API for UI
func qte_input_action() -> void:
	# HOLD läuft über qte_hold_start/qte_hold_end, sonst würde ein Druck doppelt zählen
	if qte_system and qte_system.is_active and qte_system.current_qte_type != Enums.QTEType.HOLD:
		# Forward to QTESystem's input handler
		# Create a synthetic input event for button mash/timed press
		var event = InputEventAction.new()
		event.action = "ui_accept"
		event.pressed = true
		qte_system._unhandled_input(event)

func qte_hold_start() -> void:
	if qte_system and qte_system.is_active and qte_system.current_qte_type == Enums.QTEType.HOLD:
		var event = InputEventAction.new()
		event.action = "ui_accept"
		event.pressed = true
		qte_system._unhandled_input(event)

func qte_hold_end() -> void:
	if qte_system and qte_system.is_active and qte_system.current_qte_type == Enums.QTEType.HOLD:
		var event = InputEventAction.new()
		event.action = "ui_accept"
		event.pressed = false
		qte_system._unhandled_input(event)

# =========================
# RESOURCE LOADING
# =========================

func load_all_resources() -> void:
	available_monsters = _load_resources_from_folder(MONSTERS_PATH)
	available_moves = _load_resources_from_folder(MOVES_PATH)
	available_items = _load_resources_from_folder(ITEMS_PATH)
	available_abilities = _load_resources_from_folder(ABILITIES_PATH)
	available_status_effects = _load_resources_from_folder(STATUS_PATH)
	
	_log("Loaded %d monsters, %d moves, %d items, %d abilities, %d status effects" % [
		available_monsters.size(),
		available_moves.size(),
		available_items.size(),
		available_abilities.size(),
		available_status_effects.size()
	])

func _load_resources_from_folder(path: String) -> Array:
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
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return resources

# =========================
# MONSTER SETUP
# =========================

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
		"accuracy_stage": 0,
		"evasion_stage": 0,
		"crit_stage": 0,
		"moves": [],
		"status_effects": [],
		"selected_move": null,
		"selected_move_priority": 0
	}
	
	if data.secondary_type != Enums.Type.NONE:
		monster["types"].append(data.secondary_type)
	
	monster["current_hp"] = monster["max_hp"]
	
	for level_move in data.level_up_moves:
		if level_move.level <= level:
			monster["moves"].append(level_move.move)
	
	if monster["moves"].is_empty() and available_moves.size() > 0:
		monster["moves"].append(available_moves[0])
	
	return monster

func _calculate_stat(base: int, level: int) -> int:
	return int(((2.0 * base * level) / 100.0) + level + 10)

# =========================
# BATTLE SETUP
# =========================

func set_player_monster(monster_data: MonsterData, level: int = 50, custom_moves: Array = []) -> void:
	player_monster = create_battle_monster(monster_data, level)
	if not custom_moves.is_empty():
		player_monster["moves"] = custom_moves
	player_move_pp.clear()
	for i in range(player_monster["moves"].size()):
		var move: MoveData = player_monster["moves"][i]
		player_move_pp[i] = move.MaxPP
	_log("Player selected: %s (Lv.%d)" % [player_monster["name"], level])
	player_hp_changed.emit(player_monster["current_hp"], player_monster["max_hp"])

func set_enemy_monster(monster_data: MonsterData, level: int = 50, custom_moves: Array = []) -> void:
	enemy_monster = create_battle_monster(monster_data, level)
	if not custom_moves.is_empty():
		enemy_monster["moves"] = custom_moves
	enemy_move_pp.clear()
	for i in range(enemy_monster["moves"].size()):
		var move: MoveData = enemy_monster["moves"][i]
		enemy_move_pp[i] = move.MaxPP
	_log("Enemy selected: %s (Lv.%d)" % [enemy_monster["name"], level])
	enemy_hp_changed.emit(enemy_monster["current_hp"], enemy_monster["max_hp"])

func set_player_items(items: Array) -> void:
	player_items = items
	_log("Player has %d items" % items.size())

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
	
	if is_player_turn:
		action_menu_requested.emit()
	else:
		await get_tree().create_timer(0.5).timeout
		_execute_enemy_turn()

func try_run() -> void:
	if not is_battle_active or not is_player_turn:
		return
	
	var run_chance = float(player_monster["speed"]) / float(enemy_monster["speed"]) * 50.0
	run_chance = clampf(run_chance, 20.0, 90.0)
	
	if randf() * 100.0 < run_chance:
		_log("Got away safely!")
		is_battle_active = false
		battle_ended.emit("run")
	else:
		_log("Can't escape!")
		_after_player_turn()

func execute_player_move(move_index: int) -> void:
	if not is_battle_active or not is_player_turn:
		return
	
	if move_index < 0 or move_index >= player_monster["moves"].size():
		_log("Invalid move index!")
		return
	
	var current_pp = player_move_pp.get(move_index, 0)
	if current_pp <= 0:
		_log("No PP left for this move!")
		return
	
	var move: MoveData = player_monster["moves"][move_index]
	player_monster["selected_move"] = move
	player_monster["selected_move_priority"] = move.Priority
	current_move_index = move_index
	
	player_move_pp[move_index] = current_pp - 1
	_log("%s uses %s! (PP: %d/%d)" % [player_monster["name"], move.MoveName, player_move_pp[move_index], move.MaxPP])
	moves_updated.emit()
	
	if move.HasQTE and move.QTEType != Enums.QTEType.NONE:
		current_qte_move = move
		_log("QTE Started! Type: %d, Time: %.1fs" % [move.QTEType, move.QTETimeWindow])
		qte_system.start_qte(move.QTEType, move.QTETimeWindow, move.QTEDifficulty)
	else:
		_execute_move(player_monster, enemy_monster, move, 1.0)
		_after_player_turn()

func use_item(item_index: int) -> void:
	if not is_battle_active or not is_player_turn:
		return
	
	if item_index < 0 or item_index >= player_items.size():
		_log("Invalid item index!")
		return
	
	var item: ItemData = player_items[item_index]
	_log("%s uses %s!" % [player_monster["name"], item.ItemName])
	
	_apply_item_effect(item, player_monster)
	
	if item.Consumable:
		player_items.remove_at(item_index)
		_log("%s was consumed. (%d remaining)" % [item.ItemName, player_items.size()])
		items_updated.emit()
	
	_after_player_turn()

func _apply_item_effect(item: ItemData, target: Dictionary) -> void:
	var effect_applied = false
	
	if item.RestoresHP > 0:
		var old_hp = target["current_hp"]
		target["current_hp"] = min(target["max_hp"], target["current_hp"] + item.RestoresHP)
		_log("%s restored %d HP!" % [target["name"], target["current_hp"] - old_hp])
		effect_applied = true
	
	if item.RestoresHPPercent > 0.0:
		var old_hp = target["current_hp"]
		var heal_amount = int(target["max_hp"] * item.RestoresHPPercent)
		target["current_hp"] = min(target["max_hp"], target["current_hp"] + heal_amount)
		_log("%s restored %d HP! (%.0f%%)" % [target["name"], target["current_hp"] - old_hp, item.RestoresHPPercent * 100])
		effect_applied = true
	
	if item.RestoresPP > 0:
		for i in range(player_monster["moves"].size()):
			var move: MoveData = player_monster["moves"][i]
			player_move_pp[i] = min(move.MaxPP, player_move_pp.get(i, 0) + item.RestoresPP)
		_log("Restored %d PP to all moves!" % item.RestoresPP)
		moves_updated.emit()
		effect_applied = true
	
	if item.RestoresAllPP:
		for i in range(player_monster["moves"].size()):
			var move: MoveData = player_monster["moves"][i]
			player_move_pp[i] = move.MaxPP
		_log("Fully restored PP for all moves!")
		moves_updated.emit()
		effect_applied = true
	
	# Stat boosts
	var stat_boosts = {
		"attack_stage": item.BoostAttack,
		"defense_stage": item.BoostDefense,
		"speed_stage": item.BoostSpeed,
		"special_attack_stage": item.BoostSpecialAttack,
		"special_defense_stage": item.BoostSpecialDefense,
	}
	var stat_names = {
		"attack_stage": "Attack",
		"defense_stage": "Defense",
		"speed_stage": "Speed",
		"special_attack_stage": "Sp. Attack",
		"special_defense_stage": "Sp. Defense",
	}
	for stage_key in stat_boosts:
		var boost = stat_boosts[stage_key]
		if boost > 0:
			target[stage_key] = min(6, target.get(stage_key, 0) + boost)
			_log("%s's %s rose by %d stage(s)!" % [target["name"], stat_names[stage_key], boost])
			effect_applied = true
	
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
	
	await get_tree().create_timer(0.5).timeout
	_execute_enemy_turn()

func _execute_enemy_turn() -> void:
	if not is_battle_active:
		return
	
	if enemy_monster["moves"].is_empty():
		_log("%s has no moves!" % enemy_monster["name"])
		_end_enemy_turn()
		return
	
	var valid_moves: Array = []
	for i in range(enemy_monster["moves"].size()):
		if enemy_move_pp.get(i, 0) > 0:
			valid_moves.append(i)
	
	if valid_moves.is_empty():
		_log("%s has no PP left!" % enemy_monster["name"])
		_end_enemy_turn()
		return
	
	var move_index = valid_moves[randi() % valid_moves.size()]
	var move: MoveData = enemy_monster["moves"][move_index]
	
	enemy_move_pp[move_index] = enemy_move_pp.get(move_index, 0) - 1
	_log("%s uses %s!" % [enemy_monster["name"], move.MoveName])
	
	_execute_move(enemy_monster, player_monster, move, 1.0)
	
	if _check_battle_end():
		return
	
	_end_enemy_turn()

func _end_enemy_turn() -> void:
	is_player_turn = true
	turn_changed.emit(is_player_turn)
	action_menu_requested.emit()

# =========================
# MOVE EXECUTION (uses DamageCalculator & TypeChart)
# =========================

func _execute_move(attacker: Dictionary, defender: Dictionary, move: MoveData, qte_multiplier: float) -> void:
	# Use DamageCalculator for accuracy check
	if not DamageCalculator.check_accuracy(attacker, defender, move):
		_log("%s's attack missed!" % attacker["name"])
		return
	
	if move.AttackType == Enums.AttackType.STATUS:
		_log("%s used a status move!" % attacker["name"])
		if move.InflictsStatus and move.status_effect:
			if randf() * 100.0 <= move.StatusChance:
				_apply_status(defender, move.status_effect)
		_apply_stat_changes(attacker, move, true)
		_apply_stat_changes(defender, move, false)
		return
	
	# Calculate hit count for multi-hit moves
	var hit_count = DamageCalculator.calculate_hit_count(move)
	var total_damage = 0
	
	for i in range(hit_count):
		var is_crit = DamageCalculator.check_critical_hit(attacker, move)
		
		var damage_info = DamageCalculator.calculate_damage(
			attacker, defender, move, qte_multiplier, is_crit
		)
		
		var damage = damage_info.damage
		total_damage += damage
		
		defender["current_hp"] = max(0, defender["current_hp"] - damage)
		
		# Log type effectiveness
		if damage_info.is_critical:
			_log("Critical hit!")
		if damage_info.effectiveness_text != "":
			_log(damage_info.effectiveness_text)
	
	_log("%s dealt %d damage!" % [attacker["name"], total_damage])
	
	if hit_count > 1:
		_log("Hit %d time(s)!" % hit_count)
	
	if qte_multiplier > 1.0:
		_log("QTE Bonus: x%.2f" % qte_multiplier)
	elif qte_multiplier < 1.0:
		_log("QTE Penalty: x%.2f" % qte_multiplier)
	
	# Update HP displays
	if defender == enemy_monster:
		enemy_hp_changed.emit(defender["current_hp"], defender["max_hp"])
	else:
		player_hp_changed.emit(defender["current_hp"], defender["max_hp"])
	
	# Apply recoil
	if move.Recoil > 0:
		var recoil = DamageCalculator.calculate_recoil(total_damage, move)
		attacker["current_hp"] = max(0, attacker["current_hp"] - recoil)
		_log("%s took %d recoil damage!" % [attacker["name"], recoil])
	
	# Apply drain
	if move.Drain > 0:
		var drain = DamageCalculator.calculate_drain(total_damage, move)
		attacker["current_hp"] = min(attacker["max_hp"], attacker["current_hp"] + drain)
		_log("%s recovered %d HP!" % [attacker["name"], drain])
	
	# Update attacker HP display after recoil/drain
	if move.Recoil > 0 or move.Drain > 0:
		if attacker == enemy_monster:
			enemy_hp_changed.emit(attacker["current_hp"], attacker["max_hp"])
		else:
			player_hp_changed.emit(attacker["current_hp"], attacker["max_hp"])
	
	# Check for status infliction
	if move.InflictsStatus and move.status_effect:
		if randf() * 100.0 <= move.StatusChance:
			_apply_status(defender, move.status_effect)
	
	# Check for flinch
	if DamageCalculator.check_flinch(move):
		_log("%s flinched!" % defender["name"])
	
	# Apply stat changes
	_apply_stat_changes(attacker, move, true)
	_apply_stat_changes(defender, move, false)

func _apply_stat_changes(target: Dictionary, move: MoveData, is_user: bool) -> void:
	if is_user:
		if move.UserAttackChange != 0:
			target["attack_stage"] = DamageCalculator.modify_stat_stage(target.get("attack_stage", 0), move.UserAttackChange)
			_log("%s's Attack %s!" % [target["name"], "rose" if move.UserAttackChange > 0 else "fell"])
		if move.UserDefenseChange != 0:
			target["defense_stage"] = DamageCalculator.modify_stat_stage(target.get("defense_stage", 0), move.UserDefenseChange)
			_log("%s's Defense %s!" % [target["name"], "rose" if move.UserDefenseChange > 0 else "fell"])
		if move.UserSpeedChange != 0:
			target["speed_stage"] = DamageCalculator.modify_stat_stage(target.get("speed_stage", 0), move.UserSpeedChange)
			_log("%s's Speed %s!" % [target["name"], "rose" if move.UserSpeedChange > 0 else "fell"])
	else:
		if move.TargetAttackChange != 0:
			target["attack_stage"] = DamageCalculator.modify_stat_stage(target.get("attack_stage", 0), move.TargetAttackChange)
			_log("%s's Attack %s!" % [target["name"], "rose" if move.TargetAttackChange > 0 else "fell"])
		if move.TargetDefenseChange != 0:
			target["defense_stage"] = DamageCalculator.modify_stat_stage(target.get("defense_stage", 0), move.TargetDefenseChange)
			_log("%s's Defense %s!" % [target["name"], "rose" if move.TargetDefenseChange > 0 else "fell"])
		if move.TargetSpeedChange != 0:
			target["speed_stage"] = DamageCalculator.modify_stat_stage(target.get("speed_stage", 0), move.TargetSpeedChange)
			_log("%s's Speed %s!" % [target["name"], "rose" if move.TargetSpeedChange > 0 else "fell"])

func _apply_status(target: Dictionary, status: StatusEffect) -> void:
	if not target.has("status_effects"):
		target["status_effects"] = []
	target["status_effects"].append(status)
	_log("%s was afflicted with %s!" % [target["name"], status.Name])

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

func debug_set_player_hp(hp: int) -> void:
	player_monster["current_hp"] = clamp(hp, 0, player_monster["max_hp"])
	player_hp_changed.emit(player_monster["current_hp"], player_monster["max_hp"])

func debug_set_enemy_hp(hp: int) -> void:
	enemy_monster["current_hp"] = clamp(hp, 0, enemy_monster["max_hp"])
	enemy_hp_changed.emit(enemy_monster["current_hp"], enemy_monster["max_hp"])

func debug_apply_status_to_player(status: StatusEffect) -> void:
	_apply_status(player_monster, status)

func debug_apply_status_to_enemy(status: StatusEffect) -> void:
	_apply_status(enemy_monster, status)

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

func get_player_move_pp(move_index: int) -> int:
	return player_move_pp.get(move_index, 0)

func get_player_move_max_pp(move_index: int) -> int:
	if move_index >= 0 and move_index < player_monster["moves"].size():
		var move: MoveData = player_monster["moves"][move_index]
		return move.MaxPP
	return 0
