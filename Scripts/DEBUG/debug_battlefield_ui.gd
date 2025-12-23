extends Control

## Debug Battlefield UI - Complete UI for testing battle resources

# =========================
# NODE REFERENCES
# =========================

@onready var battle_manager: DebugBattleManager = $DebugBattleManager

# Setup Panel
@onready var setup_panel: Panel = $SetupPanel
@onready var player_monster_list: ItemList = $SetupPanel/MarginContainer/VBoxContainer/HBoxContainer/PlayerSetup/MonsterList
@onready var enemy_monster_list: ItemList = $SetupPanel/MarginContainer/VBoxContainer/HBoxContainer/EnemySetup/MonsterList
@onready var player_level_spin: SpinBox = $SetupPanel/MarginContainer/VBoxContainer/HBoxContainer/PlayerSetup/LevelSpin
@onready var enemy_level_spin: SpinBox = $SetupPanel/MarginContainer/VBoxContainer/HBoxContainer/EnemySetup/LevelSpin
@onready var moves_list: ItemList = $SetupPanel/MarginContainer/VBoxContainer/HBoxContainer/MovesSetup/MovesList
@onready var player_moves_list: ItemList = $SetupPanel/MarginContainer/VBoxContainer/HBoxContainer/MovesSetup/PlayerMovesList
@onready var items_list: ItemList = $SetupPanel/MarginContainer/VBoxContainer/HBoxContainer/ItemsSetup/ItemsList
@onready var player_items_list: ItemList = $SetupPanel/MarginContainer/VBoxContainer/HBoxContainer/ItemsSetup/PlayerItemsList
@onready var start_battle_btn: Button = $SetupPanel/MarginContainer/VBoxContainer/StartBattleBtn

# Battle Panel
@onready var battle_panel: Panel = $BattlePanel
@onready var player_name_label: Label = $BattlePanel/MarginContainer/VBoxContainer/BattleArea/PlayerSide/NameLabel
@onready var player_hp_bar: ProgressBar = $BattlePanel/MarginContainer/VBoxContainer/BattleArea/PlayerSide/HPBar
@onready var player_hp_label: Label = $BattlePanel/MarginContainer/VBoxContainer/BattleArea/PlayerSide/HPLabel
@onready var player_sprite: TextureRect = $BattlePanel/MarginContainer/VBoxContainer/BattleArea/PlayerSide/SpriteContainer/Sprite

@onready var enemy_name_label: Label = $BattlePanel/MarginContainer/VBoxContainer/BattleArea/EnemySide/NameLabel
@onready var enemy_hp_bar: ProgressBar = $BattlePanel/MarginContainer/VBoxContainer/BattleArea/EnemySide/HPBar
@onready var enemy_hp_label: Label = $BattlePanel/MarginContainer/VBoxContainer/BattleArea/EnemySide/HPLabel
@onready var enemy_sprite: TextureRect = $BattlePanel/MarginContainer/VBoxContainer/BattleArea/EnemySide/SpriteContainer/Sprite

@onready var battle_log: RichTextLabel = $BattlePanel/MarginContainer/VBoxContainer/BattleLog
@onready var moves_container: HBoxContainer = $BattlePanel/MarginContainer/VBoxContainer/ActionPanel/MovesContainer
@onready var items_container: HBoxContainer = $BattlePanel/MarginContainer/VBoxContainer/ActionPanel/ItemsContainer
@onready var turn_label: Label = $BattlePanel/MarginContainer/VBoxContainer/TurnLabel

# QTE Panel
@onready var qte_panel: Panel = $QTEPanel
@onready var qte_label: Label = $QTEPanel/VBoxContainer/QTELabel
@onready var qte_bar: ProgressBar = $QTEPanel/VBoxContainer/QTEBar
@onready var qte_instruction: Label = $QTEPanel/VBoxContainer/InstructionLabel
@onready var qte_timer_label: Label = $QTEPanel/VBoxContainer/TimerLabel
@onready var qte_action_btn: Button = $QTEPanel/VBoxContainer/ActionButton

# Result Panel
@onready var result_panel: Panel = $ResultPanel
@onready var result_label: Label = $ResultPanel/VBoxContainer/ResultLabel
@onready var restart_btn: Button = $ResultPanel/VBoxContainer/RestartBtn

# Action Menu Panel
@onready var action_menu_panel: Panel = $ActionMenuPanel
@onready var fight_btn: Button = $ActionMenuPanel/VBoxContainer/FightBtn
@onready var item_btn: Button = $ActionMenuPanel/VBoxContainer/ItemBtn
@onready var run_btn: Button = $ActionMenuPanel/VBoxContainer/RunBtn

# Moves Panel (shown when Fight is selected)
@onready var moves_panel: Panel = $MovesPanel
@onready var moves_panel_container: VBoxContainer = $MovesPanel/VBoxContainer/MovesContainer
@onready var moves_back_btn: Button = $MovesPanel/VBoxContainer/BackBtn

# Items Panel (shown when Item is selected)  
@onready var items_panel: Panel = $ItemsPanel
@onready var items_panel_container: VBoxContainer = $ItemsPanel/VBoxContainer/ItemsContainer
@onready var items_back_btn: Button = $ItemsPanel/VBoxContainer/BackBtn

# =========================
# STATE
# =========================

var selected_player_moves: Array[MoveData] = []
var selected_player_items: Array[ItemData] = []
var move_buttons: Array[Button] = []
var item_buttons: Array[Button] = []

# =========================
# INITIALIZATION
# =========================

func _ready() -> void:
	# Connect signals
	battle_manager.battle_log_updated.connect(_on_battle_log_updated)
	battle_manager.player_hp_changed.connect(_on_player_hp_changed)
	battle_manager.enemy_hp_changed.connect(_on_enemy_hp_changed)
	battle_manager.qte_started.connect(_on_qte_started)
	battle_manager.qte_progress_changed.connect(_on_qte_progress_changed)
	battle_manager.qte_ended.connect(_on_qte_ended)
	battle_manager.turn_changed.connect(_on_turn_changed)
	battle_manager.battle_ended.connect(_on_battle_ended)
	battle_manager.action_menu_requested.connect(_on_action_menu_requested)
	battle_manager.moves_updated.connect(_on_moves_updated)
	battle_manager.items_updated.connect(_on_items_updated)
	
	# Button connections
	start_battle_btn.pressed.connect(_on_start_battle_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	qte_action_btn.pressed.connect(_on_qte_action_pressed)
	qte_action_btn.button_down.connect(_on_qte_hold_start)
	qte_action_btn.button_up.connect(_on_qte_hold_end)
	
	# Action menu buttons
	fight_btn.pressed.connect(_on_fight_pressed)
	item_btn.pressed.connect(_on_item_pressed)
	run_btn.pressed.connect(_on_run_pressed)
	moves_back_btn.pressed.connect(_on_moves_back_pressed)
	items_back_btn.pressed.connect(_on_items_back_pressed)
	
	# List connections
	moves_list.item_activated.connect(_on_move_add)
	player_moves_list.item_activated.connect(_on_move_remove)
	items_list.item_activated.connect(_on_item_add)
	player_items_list.item_activated.connect(_on_item_remove)
	
	# Initial state
	_show_setup_panel()
	
	# Wait for resources to load
	await get_tree().process_frame
	_populate_setup_lists()

func _input(event: InputEvent) -> void:
	if battle_manager.qte_active:
		if event.is_action_pressed("ui_accept"):
			_on_qte_action_pressed()
		if event.is_action_pressed("ui_accept"):
			_on_qte_hold_start()
		if event.is_action_released("ui_accept"):
			_on_qte_hold_end()

# =========================
# SETUP PANEL
# =========================

func _show_setup_panel() -> void:
	setup_panel.visible = true
	battle_panel.visible = false
	qte_panel.visible = false
	result_panel.visible = false
	action_menu_panel.visible = false
	moves_panel.visible = false
	items_panel.visible = false

func _populate_setup_lists() -> void:
	# Clear existing
	player_monster_list.clear()
	enemy_monster_list.clear()
	moves_list.clear()
	items_list.clear()
	player_moves_list.clear()
	player_items_list.clear()
	selected_player_moves.clear()
	selected_player_items.clear()
	
	# Populate monsters
	for monster in battle_manager.available_monsters:
		player_monster_list.add_item(monster.name)
		enemy_monster_list.add_item(monster.name)
	
	# Populate moves
	for move in battle_manager.available_moves:
		var qte_text = " [QTE]" if move.HasQTE else ""
		moves_list.add_item(move.MoveName + qte_text)
	
	# Populate items
	for item in battle_manager.available_items:
		items_list.add_item(item.ItemName)
	
	# Select first monster by default
	if player_monster_list.item_count > 0:
		player_monster_list.select(0)
	if enemy_monster_list.item_count > 0:
		enemy_monster_list.select(0)

func _on_move_add(index: int) -> void:
	if index >= 0 and index < battle_manager.available_moves.size():
		var move = battle_manager.available_moves[index]
		if move not in selected_player_moves:
			selected_player_moves.append(move)
			var qte_text = " [QTE]" if move.HasQTE else ""
			player_moves_list.add_item(move.MoveName + qte_text)

func _on_move_remove(index: int) -> void:
	if index >= 0 and index < selected_player_moves.size():
		selected_player_moves.remove_at(index)
		player_moves_list.remove_item(index)

func _on_item_add(index: int) -> void:
	if index >= 0 and index < battle_manager.available_items.size():
		var item = battle_manager.available_items[index]
		selected_player_items.append(item)
		player_items_list.add_item(item.ItemName)

func _on_item_remove(index: int) -> void:
	if index >= 0 and index < selected_player_items.size():
		selected_player_items.remove_at(index)
		player_items_list.remove_item(index)

func _on_start_battle_pressed() -> void:
	# Get selected monsters
	var player_idx = player_monster_list.get_selected_items()
	var enemy_idx = enemy_monster_list.get_selected_items()
	
	if player_idx.is_empty() or enemy_idx.is_empty():
		_log_message("[color=red]Please select both player and enemy monsters![/color]")
		return
	
	var player_monster = battle_manager.available_monsters[player_idx[0]]
	var enemy_monster = battle_manager.available_monsters[enemy_idx[0]]
	
	# Set up battle
	battle_manager.set_player_monster(
		player_monster, 
		int(player_level_spin.value),
		selected_player_moves
	)
	battle_manager.set_enemy_monster(
		enemy_monster,
		int(enemy_level_spin.value)
	)
	battle_manager.set_player_items(selected_player_items)
	
	# Show battle panel
	_show_battle_panel()
	
	# Start battle
	battle_manager.start_battle()

# =========================
# BATTLE PANEL
# =========================

func _show_battle_panel() -> void:
	setup_panel.visible = false
	battle_panel.visible = true
	qte_panel.visible = false
	result_panel.visible = false
	action_menu_panel.visible = false
	moves_panel.visible = false
	items_panel.visible = false
	
	# Update monster displays
	_update_battle_display()
	
	# Clear log
	battle_log.clear()

func _update_battle_display() -> void:
	# Player side
	player_name_label.text = "%s Lv.%d" % [
		battle_manager.player_monster["name"],
		battle_manager.player_monster["level"]
	]
	player_hp_bar.max_value = battle_manager.player_monster["max_hp"]
	player_hp_bar.value = battle_manager.player_monster["current_hp"]
	player_hp_label.text = "%d / %d" % [
		battle_manager.player_monster["current_hp"],
		battle_manager.player_monster["max_hp"]
	]
	
	var player_data: MonsterData = battle_manager.player_monster["data"]
	if player_data.sprite:
		player_sprite.texture = player_data.sprite
	
	# Enemy side
	enemy_name_label.text = "%s Lv.%d" % [
		battle_manager.enemy_monster["name"],
		battle_manager.enemy_monster["level"]
	]
	enemy_hp_bar.max_value = battle_manager.enemy_monster["max_hp"]
	enemy_hp_bar.value = battle_manager.enemy_monster["current_hp"]
	enemy_hp_label.text = "%d / %d" % [
		battle_manager.enemy_monster["current_hp"],
		battle_manager.enemy_monster["max_hp"]
	]
	
	var enemy_data: MonsterData = battle_manager.enemy_monster["data"]
	if enemy_data.sprite:
		enemy_sprite.texture = enemy_data.sprite

func _create_move_buttons() -> void:
	# Clear existing
	for btn in move_buttons:
		btn.queue_free()
	move_buttons.clear()
	
	# Create new buttons in moves panel
	var moves: Array = battle_manager.player_monster["moves"]
	for i in range(moves.size()):
		var move: MoveData = moves[i]
		var current_pp = battle_manager.get_player_move_pp(i)
		var max_pp = move.MaxPP
		
		var btn = Button.new()
		var qte_marker = " ★" if move.HasQTE else ""
		btn.text = "%s%s\nPP: %d/%d" % [move.MoveName, qte_marker, current_pp, max_pp]
		btn.custom_minimum_size = Vector2(200, 60)
		btn.pressed.connect(_on_move_button_pressed.bind(i))
		
		# Disable if no PP
		if current_pp <= 0:
			btn.disabled = true
			btn.modulate = Color(0.5, 0.5, 0.5)
		
		moves_panel_container.add_child(btn)
		move_buttons.append(btn)

func _create_item_buttons() -> void:
	# Clear existing
	for btn in item_buttons:
		btn.queue_free()
	item_buttons.clear()
	
	# Create new buttons in items panel using battle_manager's item list
	var items = battle_manager.player_items
	for i in range(items.size()):
		var item: ItemData = items[i]
		var btn = Button.new()
		btn.text = item.ItemName
		if item.RestoresHP > 0:
			btn.text += "\n(HP +%d)" % item.RestoresHP
		elif item.RestoresHPPercent > 0:
			btn.text += "\n(HP +%.0f%%)" % (item.RestoresHPPercent * 100)
		btn.custom_minimum_size = Vector2(200, 50)
		btn.pressed.connect(_on_item_button_pressed.bind(i))
		items_panel_container.add_child(btn)
		item_buttons.append(btn)
	
	# Show message if no items
	if items.is_empty():
		var label = Label.new()
		label.text = "No items!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		items_panel_container.add_child(label)

# =========================
# ACTION MENU
# =========================

func _on_action_menu_requested() -> void:
	action_menu_panel.visible = true
	moves_panel.visible = false
	items_panel.visible = false

func _on_fight_pressed() -> void:
	action_menu_panel.visible = false
	moves_panel.visible = true
	_create_move_buttons()

func _on_item_pressed() -> void:
	action_menu_panel.visible = false
	items_panel.visible = true
	_create_item_buttons()

func _on_run_pressed() -> void:
	action_menu_panel.visible = false
	battle_manager.try_run()

func _on_moves_back_pressed() -> void:
	moves_panel.visible = false
	action_menu_panel.visible = true

func _on_items_back_pressed() -> void:
	items_panel.visible = false
	action_menu_panel.visible = true

func _on_moves_updated() -> void:
	# Refresh move buttons to show updated PP
	if moves_panel.visible:
		_create_move_buttons()

func _on_items_updated() -> void:
	# Refresh item buttons when items change
	if items_panel.visible:
		_create_item_buttons()

func _on_move_button_pressed(index: int) -> void:
	if battle_manager.is_player_turn and battle_manager.is_battle_active:
		moves_panel.visible = false
		battle_manager.execute_player_move(index)

func _on_item_button_pressed(index: int) -> void:
	if battle_manager.is_player_turn and battle_manager.is_battle_active:
		items_panel.visible = false
		battle_manager.use_item(index)

# =========================
# QTE PANEL
# =========================

func _on_qte_started(qte_type: int, time_window: float) -> void:
	qte_panel.visible = true
	qte_bar.value = 0
	qte_bar.max_value = 100
	
	var type_names = ["NONE", "BUTTON MASH", "TIMED PRESS", "SEQUENCE", "HOLD", "RHYTHM"]
	qte_label.text = "QTE: %s" % type_names[qte_type]
	
	match qte_type:
		MoveData.e_QTEType.BUTTON_MASH:
			qte_instruction.text = "Mash the button rapidly!"
			qte_action_btn.text = "MASH!"
		MoveData.e_QTEType.TIMED_PRESS:
			qte_instruction.text = "Press when the bar reaches the middle!"
			qte_action_btn.text = "PRESS!"
		MoveData.e_QTEType.HOLD:
			qte_instruction.text = "Hold the button!"
			qte_action_btn.text = "HOLD"
		_:
			qte_instruction.text = "Press the button!"
			qte_action_btn.text = "ACTION"
	
	_set_action_buttons_enabled(false)

func _on_qte_progress_changed(progress: float) -> void:
	qte_bar.value = progress * 100
	qte_timer_label.text = "%.1fs" % battle_manager.qte_time_remaining

func _on_qte_ended(success: bool, level: float) -> void:
	qte_panel.visible = false
	_set_action_buttons_enabled(true)
	
	if success:
		_log_message("[color=green]QTE Success! (%.0f%%)[/color]" % (level * 100))
	else:
		_log_message("[color=red]QTE Failed![/color]")

func _on_qte_action_pressed() -> void:
	battle_manager.qte_input_action()

func _on_qte_hold_start() -> void:
	battle_manager.qte_hold_start()

func _on_qte_hold_end() -> void:
	battle_manager.qte_hold_end()

# =========================
# TURN MANAGEMENT
# =========================

func _on_turn_changed(is_player_turn: bool) -> void:
	if is_player_turn:
		turn_label.text = "YOUR TURN"
		turn_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		turn_label.text = "ENEMY TURN"
		turn_label.add_theme_color_override("font_color", Color.RED)
	
	_set_action_buttons_enabled(is_player_turn)

func _set_action_buttons_enabled(enabled: bool) -> void:
	for btn in move_buttons:
		btn.disabled = not enabled
	for btn in item_buttons:
		btn.disabled = not enabled

# =========================
# HP UPDATES
# =========================

func _on_player_hp_changed(current: int, max_hp: int) -> void:
	player_hp_bar.max_value = max_hp
	player_hp_bar.value = current
	player_hp_label.text = "%d / %d" % [current, max_hp]
	
	# Color based on HP percentage
	var percent = float(current) / float(max_hp)
	if percent > 0.5:
		player_hp_bar.modulate = Color.GREEN
	elif percent > 0.25:
		player_hp_bar.modulate = Color.YELLOW
	else:
		player_hp_bar.modulate = Color.RED

func _on_enemy_hp_changed(current: int, max_hp: int) -> void:
	enemy_hp_bar.max_value = max_hp
	enemy_hp_bar.value = current
	enemy_hp_label.text = "%d / %d" % [current, max_hp]
	
	var percent = float(current) / float(max_hp)
	if percent > 0.5:
		enemy_hp_bar.modulate = Color.GREEN
	elif percent > 0.25:
		enemy_hp_bar.modulate = Color.YELLOW
	else:
		enemy_hp_bar.modulate = Color.RED

# =========================
# BATTLE END
# =========================

func _on_battle_ended(winner: String) -> void:
	# Hide action panels
	action_menu_panel.visible = false
	moves_panel.visible = false
	items_panel.visible = false
	result_panel.visible = true
	
	if winner == "player":
		result_label.text = "VICTORY!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
	elif winner == "run":
		result_label.text = "GOT AWAY!"
		result_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		result_label.text = "DEFEAT!"
		result_label.add_theme_color_override("font_color", Color.RED)

func _on_restart_pressed() -> void:
	# Reset and go back to setup
	_populate_setup_lists()
	_show_setup_panel()

# =========================
# LOGGING
# =========================

func _on_battle_log_updated(message: String) -> void:
	_log_message(message)

func _log_message(message: String) -> void:
	battle_log.append_text(message + "\n")
	# Auto-scroll to bottom
	await get_tree().process_frame
	battle_log.scroll_to_line(battle_log.get_line_count())
