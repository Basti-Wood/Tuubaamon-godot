extends Node
class_name BattleSystem

## Main battle system that integrates QTE, damage calculation, and turn management

# =========================
# SIGNALS
# =========================

signal battle_started()
signal turn_started(battler)
signal move_selected(battler, move)
signal qte_initiated(move)
signal damage_dealt(attacker, defender, damage_info)
signal battle_ended(winner)
signal status_applied(target, status)
signal stat_changed(target, stat_name, stages)

# =========================
# REFERENCES
# =========================

@onready var qte_system: QTESystem = $QTESystem
var damage_calculator = DamageCalculator

# =========================
# BATTLE STATE
# =========================

var is_active: bool = false
var current_turn: int = 0
var weather: String = "none"
var terrain: String = "none"

# Battlers
var player_monsters: Array = []
var enemy_monsters: Array = []
var active_player_monster = null
var active_enemy_monster = null

# Turn queue
var turn_queue: Array = []
var current_battler = null

# =========================
# INITIALIZATION
# =========================

func _ready() -> void:
	if not qte_system:
		qte_system = QTESystem.new()
		add_child(qte_system)
	
	qte_system.qte_completed.connect(_on_qte_completed)
	qte_system.qte_failed.connect(_on_qte_failed)

# =========================
# BATTLE MANAGEMENT
# =========================

## Start a battle
func start_battle(player_team: Array, enemy_team: Array) -> void:
	if is_active:
		push_warning("Battle already active!")
		return
	
	is_active = true
	current_turn = 0
	weather = "none"
	terrain = "none"
	
	player_monsters = player_team
	enemy_monsters = enemy_team
	
	# Set active monsters (first in party)
	if player_monsters.size() > 0:
		active_player_monster = player_monsters[0]
	
	if enemy_monsters.size() > 0:
		active_enemy_monster = enemy_monsters[0]
	
	battle_started.emit()
	
	# Start first turn
	start_turn()

## End the battle
func end_battle(winner: String) -> void:
	is_active = false
	battle_ended.emit(winner)

# =========================
# TURN MANAGEMENT
# =========================

## Start a new turn
func start_turn() -> void:
	current_turn += 1
	
	# Build turn queue based on speed and priority
	turn_queue = _build_turn_queue()
	
	# Execute turns
	_execute_next_turn()

## Build turn order based on speed
func _build_turn_queue() -> Array:
	var queue = []
	
	# Add all active battlers
	if active_player_monster:
		queue.append({
			"battler": active_player_monster,
			"is_player": true,
			"speed": active_player_monster.get("speed", 50),
			"priority": active_player_monster.get("selected_move_priority", 0)
		})
	
	if active_enemy_monster:
		queue.append({
			"battler": active_enemy_monster,
			"is_player": false,
			"speed": active_enemy_monster.get("speed", 50),
			"priority": active_enemy_monster.get("selected_move_priority", 0)
		})
	
	# Sort by priority first, then speed
	queue.sort_custom(func(a, b):
		if a.priority != b.priority:
			return a.priority > b.priority
		return a.speed > b.speed
	)
	
	return queue

## Execute next battler's turn
func _execute_next_turn() -> void:
	if turn_queue.is_empty():
		# All turns done, start new turn
		start_turn()
		return
	
	current_battler = turn_queue.pop_front()
	turn_started.emit(current_battler)
	
	# Get the selected move
	var move = current_battler.battler.get("selected_move")
	if not move:
		push_warning("No move selected!")
		_execute_next_turn()
		return
	
	# Execute the move
	execute_move(current_battler, move)

# =========================
# MOVE EXECUTION
# =========================

## Execute a move
func execute_move(battler_data: Dictionary, move: MoveData) -> void:
	var attacker = battler_data.battler
	var is_player = battler_data.is_player
	
	# Determine target
	var defender = active_enemy_monster if is_player else active_player_monster
	
	move_selected.emit(attacker, move)
	
	# Check if move has QTE
	if move.HasQTE and move.QTEType != MoveData.e_QTEType.NONE:
		# Initiate QTE
		qte_initiated.emit(move)
		qte_system.start_qte(move.QTEType, move.QTETimeWindow, move.QTEDifficulty)
		
		# Store move data for when QTE completes
		attacker["pending_move"] = move
		attacker["pending_defender"] = defender
	else:
		# No QTE, execute immediately
		_finalize_move_execution(attacker, defender, move, 1.0)

## Called when QTE completes
func _on_qte_completed(success_level: float) -> void:
	var attacker = current_battler.battler
	var move = attacker.get("pending_move")
	var defender = attacker.get("pending_defender")
	
	if not move or not defender:
		push_warning("No pending move after QTE!")
		_execute_next_turn()
		return
	
	# Get QTE multiplier
	var qte_multiplier = qte_system.get_damage_multiplier(move)
	
	# Execute the move with QTE multiplier
	_finalize_move_execution(attacker, defender, move, qte_multiplier)

## Called when QTE fails
func _on_qte_failed() -> void:
	var attacker = current_battler.battler
	var move = attacker.get("pending_move")
	var defender = attacker.get("pending_defender")
	
	if move and defender:
		# Execute with failure multiplier
		_finalize_move_execution(attacker, defender, move, move.QTEFailureMultiplier)
	else:
		_execute_next_turn()

## Finalize move execution after QTE or immediately
func _finalize_move_execution(
	attacker: Dictionary,
	defender: Dictionary,
	move: MoveData,
	qte_multiplier: float
) -> void:
	
	# Check accuracy
	if not damage_calculator.check_accuracy(attacker, defender, move):
		print("%s's move missed!" % attacker.get("name", "Monster"))
		_execute_next_turn()
		return
	
	# Check for multi-hit
	var hit_count = damage_calculator.calculate_hit_count(move)
	var total_damage = 0
	
	for i in range(hit_count):
		# Check for critical hit
		var is_crit = damage_calculator.check_critical_hit(attacker, move)
		
		# Get weather modifier
		var weather_mod = damage_calculator.get_weather_modifier(weather, move.MoveType)
		
		# Calculate damage
		var damage_info = damage_calculator.calculate_damage(
			attacker,
			defender,
			move,
			qte_multiplier,
			is_crit,
			weather_mod
		)
		
		var damage = damage_info.damage
		total_damage += damage
		
		# Apply damage
		defender["current_hp"] = max(0, defender.get("current_hp", 100) - damage)
		
		# Emit damage event
		damage_dealt.emit(attacker, defender, damage_info)
		
		# Print battle text
		print("%s used %s!" % [attacker.get("name", "Monster"), move.MoveName])
		if damage_info.is_critical:
			print("A critical hit!")
		if damage_info.effectiveness_text:
			print(damage_info.effectiveness_text)
		print("%s took %d damage!" % [defender.get("name", "Monster"), damage])
	
	# Apply recoil
	if move.Recoil > 0:
		var recoil = damage_calculator.calculate_recoil(total_damage, move)
		attacker["current_hp"] = max(0, attacker.get("current_hp", 100) - recoil)
		print("%s took %d recoil damage!" % [attacker.get("name", "Monster"), recoil])
	
	# Apply drain
	if move.Drain > 0:
		var drain = damage_calculator.calculate_drain(total_damage, move)
		attacker["current_hp"] = min(attacker.get("max_hp", 100), attacker.get("current_hp", 100) + drain)
		print("%s recovered %d HP!" % [attacker.get("name", "Monster"), drain])
	
	# Check for status effect
	if damage_calculator.check_status_infliction(move):
		if move.StatusEffect:
			_apply_status(defender, move.StatusEffect)
	
	# Check for flinch
	if damage_calculator.check_flinch(move):
		print("%s flinched!" % defender.get("name", "Monster"))
		# Handle flinch logic (skip next turn)
	
	# Apply stat changes
	_apply_stat_changes(attacker, move, true)
	_apply_stat_changes(defender, move, false)
	
	# Check if defender fainted
	if defender.get("current_hp", 0) <= 0:
		print("%s fainted!" % defender.get("name", "Monster"))
		_handle_faint(defender)
	
	# Continue to next turn
	_execute_next_turn()

# =========================
# STATUS EFFECTS
# =========================

func _apply_status(target: Dictionary, status: StatusEffect) -> void:
	if not target.has("status_effects"):
		target["status_effects"] = []
	
	# Check if status can be applied
	if status.CanStack or not _has_status(target, status.Name):
		target["status_effects"].append({
			"status": status,
			"turns_remaining": status.MaxTurns
		})
		status_applied.emit(target, status)
		print("%s was afflicted with %s!" % [target.get("name", "Monster"), status.Name])

func _has_status(target: Dictionary, status_name: String) -> bool:
	if not target.has("status_effects"):
		return false
	
	for status_data in target["status_effects"]:
		if status_data.status.Name == status_name:
			return true
	
	return false

# =========================
# STAT CHANGES
# =========================

func _apply_stat_changes(target: Dictionary, move: MoveData, is_user: bool) -> void:
	var changes = {}
	
	if is_user:
		if move.UserAttackChange != 0:
			changes["attack"] = move.UserAttackChange
		if move.UserDefenseChange != 0:
			changes["defense"] = move.UserDefenseChange
		if move.UserSpeedChange != 0:
			changes["speed"] = move.UserSpeedChange
	else:
		if move.TargetAttackChange != 0:
			changes["attack"] = move.TargetAttackChange
		if move.TargetDefenseChange != 0:
			changes["defense"] = move.TargetDefenseChange
		if move.TargetSpeedChange != 0:
			changes["speed"] = move.TargetSpeedChange
	
	for stat_name in changes:
		var stage_key = stat_name + "_stage"
		var current_stage = target.get(stage_key, 0)
		var new_stage = damage_calculator.modify_stat_stage(current_stage, changes[stat_name])
		target[stage_key] = new_stage
		
		stat_changed.emit(target, stat_name, changes[stat_name])
		
		if changes[stat_name] > 0:
			print("%s's %s rose!" % [target.get("name", "Monster"), stat_name])
		else:
			print("%s's %s fell!" % [target.get("name", "Monster"), stat_name])

# =========================
# FAINTING
# =========================

func _handle_faint(monster: Dictionary) -> void:
	# Check if battle is over
	var player_has_monsters = _has_active_monsters(player_monsters)
	var enemy_has_monsters = _has_active_monsters(enemy_monsters)
	
	if not player_has_monsters:
		end_battle("enemy")
	elif not enemy_has_monsters:
		end_battle("player")
	else:
		# Switch to next available monster
		# This would trigger a switch UI in a real implementation
		pass

func _has_active_monsters(team: Array) -> bool:
	for monster in team:
		if monster.get("current_hp", 0) > 0:
			return true
	return false
