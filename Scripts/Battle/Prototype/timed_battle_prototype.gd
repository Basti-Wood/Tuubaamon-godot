extends Control

## Prototyp: 1-gegen-1-Kampf mit Action Commands (Mario & Luigi / Paper Mario).
## - Angriff: Leertaste/Enter drücken, wenn der Ring den Kreis berührt -> mehr Schaden.
## - Verteidigung: beim gegnerischen Aufprall drücken -> weniger Schaden, exzellent = ausgewichen.
## - Gegner-Attacken bekommen ebenfalls eine Timing-Stufe (über "Präzision").
## - Krits sind getrennt und hängen an Glück.
## - Jede Attacke (auch Status) hat ein Timing. Wann gedrückt wird, steht in der Attacke (TimingHits).
## Rechnet Schaden über DamageCalculator / TypeChart. Die UI wird im Code gebaut,
## damit keine bestehende Szene angefasst wird.

# =========================
# SIGNALS
# =========================

signal move_chosen(move: MoveData)

# =========================
# SETTINGS
# =========================

const FALLBACK_MOVE: MoveData = preload("res://Resources/Moves/scratch.tres")
const TIER_COLORS: Array[Color] = [
	Color(0.6, 0.6, 0.6),   # schlecht
	Color(0.9, 0.9, 0.5),   # okay
	Color(0.5, 0.95, 0.5),  # gut
	Color(0.4, 0.75, 1.0),  # sehr gut
	Color(1.0, 0.8, 0.2),   # exzellent
]

@export var player_monster: MonsterData = preload("res://Resources/Monsters/Fuego.tres")
@export var enemy_monster: MonsterData = preload("res://Resources/Monsters/BisBomb.tres")
@export_range(1, 100) var level: int = 20

## Arbeitsname "Präzision": ca. 0.3 = Dumm, 0.55 = Mittel, 0.85 = Klug
@export_range(0.0, 1.0) var enemy_precision: float = 0.55

## Platzhalter, bis MonsterData einen Glück-Wert hat. Krit-Chance = Glück / 4 %.
@export_range(0, 100) var player_luck: int = 20
@export_range(0, 100) var enemy_luck: int = 20

## Die Monster haben noch keine Basiswerte (alle 1), daher mehr KP, damit der Kampf ein paar Runden hält
@export var prototype_hp_multiplier: float = 4.0

@export var auto_timing: bool = false
@export_range(0.25, 3.0) var timing_window_scale: float = 1.0

## Die Aufprall-Zeitpunkte kommen aus jeder Attacke (MoveData.TimingHits).

# =========================
# STATE
# =========================

var player: Dictionary = {}
var enemy: Dictionary = {}
var is_over: bool = false

var command: ActionCommand
var ring: TimingRing

var player_sprite: Sprite2D
var enemy_sprite: Sprite2D
var player_home: Vector2
var enemy_home: Vector2
var player_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var player_hp_label: Label
var enemy_hp_label: Label
var hint_label: Label
var move_menu: HBoxContainer
var battle_log: RichTextLabel
var result_panel: PanelContainer
var result_label: Label

# =========================
# INITIALIZATION
# =========================

func _ready() -> void:
	command = ActionCommand.new()
	command.name = "ActionCommand"
	command.auto_timing = auto_timing
	command.window_scale = timing_window_scale
	add_child(command)

	player = _make_battler(player_monster, player_luck)
	enemy = _make_battler(enemy_monster, enemy_luck)

	_build_ui()
	_update_hp()
	_battle_loop()

func _make_battler(data: MonsterData, luck: int) -> Dictionary:
	var battler = {
		"data": data,
		"name": data.name,
		"level": level,
		"types": [data.primary_type],
		"max_hp": int(DamageCalculator.calculate_max_hp(data.base_hp, level) * prototype_hp_multiplier),
		"attack": DamageCalculator.calculate_stat(data.base_attack, level),
		"defense": DamageCalculator.calculate_stat(data.base_defense, level),
		"special_attack": DamageCalculator.calculate_stat(data.base_special_attack, level),
		"special_defense": DamageCalculator.calculate_stat(data.base_special_defense, level),
		"speed": DamageCalculator.calculate_stat(data.base_speed, level),
		"luck": luck,
		"attack_stage": 0,
		"defense_stage": 0,
		"speed_stage": 0,
		"accuracy_stage": 0,
		"evasion_stage": 0,
		"moves": [],
	}
	battler["current_hp"] = battler["max_hp"]

	if data.secondary_type != Enums.Type.NONE:
		battler["types"].append(data.secondary_type)

	for level_move in data.level_up_moves:
		if level_move and level_move.move and level_move.level <= level and battler["moves"].size() < 4:
			battler["moves"].append(level_move.move)

	if battler["moves"].is_empty():
		battler["moves"].append(FALLBACK_MOVE)

	return battler

# =========================
# UI
# =========================

func _build_ui() -> void:
	var screen = get_viewport_rect().size

	var background = ColorRect.new()
	background.color = Color(0.13, 0.15, 0.22)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	player_home = Vector2(screen.x * 0.25, screen.y * 0.55)
	enemy_home = Vector2(screen.x * 0.75, screen.y * 0.40)
	player_sprite = _make_sprite(player["data"], player_home, false)
	enemy_sprite = _make_sprite(enemy["data"], enemy_home, true)

	player_hp_label = _make_label(player_home + Vector2(-110, -150), 20)
	player_hp_bar = _make_hp_bar(player_home + Vector2(-110, -120))
	enemy_hp_label = _make_label(enemy_home + Vector2(-110, -150), 20)
	enemy_hp_bar = _make_hp_bar(enemy_home + Vector2(-110, -120))

	ring = TimingRing.new()
	ring.command = command
	ring.z_index = 10
	add_child(ring)

	hint_label = _make_label(Vector2(0, 16), 22)
	hint_label.size = Vector2(screen.x, 40)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var info = _make_label(Vector2(16, screen.y - 210), 14)
	info.modulate = Color(1, 1, 1, 0.6)
	info.text = "Gegner-Präzision %.2f · Glück %d / %d · Auto-Timing %s" % [
		enemy_precision, player_luck, enemy_luck, "an" if auto_timing else "aus"
	]

	move_menu = HBoxContainer.new()
	move_menu.position = Vector2(16, screen.y - 180)
	move_menu.add_theme_constant_override("separation", 12)
	add_child(move_menu)
	for move in player["moves"]:
		var button = Button.new()
		button.text = "%s  (%d)" % [move.MoveName, move.Damage]
		button.custom_minimum_size = Vector2(170, 48)
		button.pressed.connect(func(): move_chosen.emit(move))
		move_menu.add_child(button)
	move_menu.visible = false

	battle_log = RichTextLabel.new()
	battle_log.position = Vector2(16, screen.y - 120)
	battle_log.size = Vector2(screen.x - 32, 110)
	battle_log.scroll_following = true
	battle_log.add_theme_font_size_override("normal_font_size", 15)
	add_child(battle_log)

	result_panel = PanelContainer.new()
	result_panel.position = Vector2(screen.x * 0.5 - 160, screen.y * 0.35)
	result_panel.custom_minimum_size = Vector2(320, 140)
	var box = VBoxContainer.new()
	result_panel.add_child(box)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 32)
	box.add_child(result_label)
	var restart = Button.new()
	restart.text = "Nochmal"
	restart.pressed.connect(func(): get_tree().reload_current_scene())
	box.add_child(restart)
	result_panel.z_index = 20
	result_panel.visible = false
	add_child(result_panel)

func _make_sprite(data: MonsterData, pos: Vector2, flip: bool) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = data.sprite
	sprite.position = pos
	sprite.flip_h = flip
	if sprite.texture:
		var tex_size = sprite.texture.get_size()
		sprite.scale = Vector2.ONE * (128.0 / maxf(tex_size.x, tex_size.y))
	add_child(sprite)
	return sprite

func _make_label(pos: Vector2, font_size: int) -> Label:
	var label = Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label

func _make_hp_bar(pos: Vector2) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.position = pos
	bar.size = Vector2(220, 20)
	bar.show_percentage = false
	add_child(bar)
	return bar

func _update_hp() -> void:
	for pair in [[player, player_hp_bar, player_hp_label], [enemy, enemy_hp_bar, enemy_hp_label]]:
		var battler: Dictionary = pair[0]
		pair[1].max_value = battler["max_hp"]
		create_tween().tween_property(pair[1], "value", float(battler["current_hp"]), 0.3)
		pair[2].text = "%s  Lv.%d   KP %d/%d" % [battler["name"], battler["level"], battler["current_hp"], battler["max_hp"]]

func _popup(text: String, pos: Vector2, color: Color, font_size: int = 30) -> void:
	var label = _make_label(pos + Vector2(-100, 0), font_size)
	label.text = text
	label.size = Vector2(200, 40)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = color
	label.z_index = 15
	var tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50.0, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)

func _log(message: String) -> void:
	print("[TIMED BATTLE] " + message)
	battle_log.append_text(message + "\n")

# =========================
# BATTLE FLOW
# =========================

func _battle_loop() -> void:
	_log("=== %s gegen %s ===" % [player["name"], enemy["name"]])

	while not is_over:
		# Initiative entscheidet, wer zuerst handelt
		var player_first = _initiative(player) >= _initiative(enemy)
		for is_player_turn in ([true, false] if player_first else [false, true]):
			if is_player_turn:
				await _player_turn()
			else:
				await _enemy_turn()
			if _check_end():
				return

## Initiative inklusive Stufen, damit Attacken wie "Initiative sinkt" die Reihenfolge ändern
func _initiative(battler: Dictionary) -> float:
	return battler["speed"] * DamageCalculator.get_stat_stage_multiplier(battler.get("speed_stage", 0))

func _player_turn() -> void:
	hint_label.text = "Wähle eine Attacke"
	move_menu.visible = true
	move_menu.get_child(0).grab_focus()
	var move: MoveData = await move_chosen
	move_menu.visible = false
	hint_label.text = "Drücke [Leertaste], wenn der Ring den Kreis berührt! (%d×)" % move.get_timing_hits().size()
	await _perform_attack(player, enemy, move, true)
	hint_label.text = ""

func _enemy_turn() -> void:
	var move: MoveData = enemy["moves"].pick_random()
	await get_tree().create_timer(0.4).timeout
	if move.AttackType == Enums.AttackType.STATUS or move.Damage <= 0:
		hint_label.text = "Der Gegner bereitet sich vor ..."
	else:
		hint_label.text = "Verteidigen: drücke [Leertaste] beim Aufprall! (%d×)" % move.get_timing_hits().size()
	await _perform_attack(enemy, player, move, false)
	hint_label.text = ""

func _perform_attack(attacker: Dictionary, defender: Dictionary, move: MoveData, attacker_is_player: bool) -> void:
	var attacker_sprite = player_sprite if attacker_is_player else enemy_sprite
	var defender_sprite = enemy_sprite if attacker_is_player else player_sprite
	var attacker_home = player_home if attacker_is_player else enemy_home
	var is_status = move.AttackType == Enums.AttackType.STATUS or move.Damage <= 0

	_log("%s setzt %s ein!" % [attacker["name"], move.MoveName])

	# Jede Attacke hat ein Timing. Die Aufpralle stehen in der Attacke (TimingHits),
	# die Platzhalter-Animation trifft genau zu diesen Zeitpunkten.
	var hit_times = move.get_timing_hits()
	ring.position = attacker_sprite.position if is_status else defender_sprite.position
	# Status-Attacken des Gegners: nur sein Timing wird ausgewürfelt, du musst nichts drücken
	command.auto_timing = auto_timing or (is_status and not attacker_is_player)
	command.start_for_move(move)
	var animation = _status_animation(attacker_sprite, attacker_home, hit_times) if is_status \
		else _attack_animation(attacker_sprite, attacker_home, defender_sprite.position, hit_times)

	var attack_tiers: Array[int] = []
	var defense_tiers: Array[int] = []
	while command.is_active:
		var judged: Array = await command.hit_judged
		var pressed_tier: int = judged[1]
		var offset_ms: float = judged[2] * 1000.0
		var hit_label = "" if hit_times.size() == 1 else " %d/%d" % [judged[0] + 1, hit_times.size()]
		if attacker_is_player or is_status:
			attack_tiers.append(pressed_tier if attacker_is_player else ActionCommand.roll_enemy_tier(enemy_precision))
			var shown = attack_tiers.back()
			ring.flash(TIER_COLORS[shown])
			_popup(ActionCommand.TIER_NAMES[shown], ring.position + Vector2(0, -110), TIER_COLORS[shown])
			_log("  Timing%s: %s (%+.0f ms)" % [hit_label, ActionCommand.TIER_NAMES[shown], offset_ms])
		else:
			var enemy_tier = ActionCommand.roll_enemy_tier(enemy_precision)
			attack_tiers.append(enemy_tier)
			defense_tiers.append(pressed_tier)
			ring.flash(TIER_COLORS[pressed_tier])
			_popup(ActionCommand.TIER_NAMES[enemy_tier], attacker_home + Vector2(0, -110), TIER_COLORS[enemy_tier], 22)
			_popup(_defense_text(pressed_tier), defender_sprite.position + Vector2(0, -110), TIER_COLORS[pressed_tier])
			_log("  Gegner-Timing%s: %s · Verteidigung: %s (%+.0f ms)" % [
				hit_label, ActionCommand.TIER_NAMES[enemy_tier], _defense_text(pressed_tier), offset_ms
			])
	if animation.is_running():
		await animation.finished

	if is_status:
		# TODO: Soll das Timing Status-Attacken stärker/schwächer machen? (offen, Design-Dokument)
		_apply_stat_changes(attacker, defender, move)
		await get_tree().create_timer(0.4).timeout
	elif move.IsMultiHit:
		# Mehrfachtreffer: jeder Druck ist ein eigener Treffer mit eigener Stufe
		for i in range(attack_tiers.size()):
			var defense_tier = defense_tiers[i] if i < defense_tiers.size() else ActionCommand.Tier.SCHLECHT
			await _resolve_hit(attacker, defender, move, attack_tiers[i], defense_tier, defender_sprite, i == attack_tiers.size() - 1)
			if defender["current_hp"] <= 0:
				break
	else:
		# Ein Treffer: Durchschnitt aller Drücke
		var defense_tier = ActionCommand.average_tier(defense_tiers) if not defense_tiers.is_empty() else ActionCommand.Tier.SCHLECHT
		await _resolve_hit(attacker, defender, move, ActionCommand.average_tier(attack_tiers), defense_tier, defender_sprite, true)

	var back = create_tween()
	back.tween_property(attacker_sprite, "position", attacker_home, 0.3)
	await back.finished

## Ein Treffer. Bei Mehrfachtreffern wird das für jeden Druck einzeln aufgerufen,
## Werte-Änderungen gibt es nur beim letzten (apply_effects).
func _resolve_hit(attacker: Dictionary, defender: Dictionary, move: MoveData, attack_tier: int, defense_tier: int, defender_sprite: Sprite2D, apply_effects: bool) -> void:
	if not DamageCalculator.check_accuracy(attacker, defender, move):
		_popup("Daneben!", defender_sprite.position + Vector2(0, -60), Color.WHITE)
		_log("  Daneben!")
		return

	var defense_multiplier = ActionCommand.DEFENSE_MULTIPLIERS[defense_tier]
	if defense_multiplier <= 0.0:
		_log("  %s ist komplett ausgewichen!" % defender["name"])
		_dodge(defender_sprite)
		return

	var timing_multiplier = ActionCommand.ATTACK_MULTIPLIERS[attack_tier] * defense_multiplier
	var crit_chance = attacker["luck"] / 4.0 + move.CritRateBonus
	var is_crit = randf() * 100.0 < crit_chance
	var info = DamageCalculator.calculate_damage(attacker, defender, move, timing_multiplier, is_crit)
	var total_damage: int = info.damage

	defender["current_hp"] = maxi(0, defender["current_hp"] - total_damage)
	_update_hp()
	_shake(defender_sprite)
	_popup(str(total_damage), defender_sprite.position + Vector2(0, -60), Color(1, 0.45, 0.4), 36)

	var details = "x%.2f Timing" % timing_multiplier
	if is_crit:
		details += ", Volltreffer (Glück)"
		_popup("Volltreffer!", defender_sprite.position + Vector2(0, 40), Color(1, 0.6, 1), 24)
	if info.get("effectiveness_text", "") != "":
		details += ", " + info.effectiveness_text
	_log("  %d Schaden (%s)" % [total_damage, details])

	if apply_effects:
		_apply_stat_changes(attacker, defender, move)
	await get_tree().create_timer(0.35 if apply_effects else 0.15).timeout

func _defense_text(tier: int) -> String:
	match tier:
		ActionCommand.Tier.EXZELLENT:
			return "Ausgewichen!"
		ActionCommand.Tier.SEHR_GUT:
			return "Geblockt!"
		ActionCommand.Tier.GUT:
			return "Abgewehrt"
		ActionCommand.Tier.OKAY:
			return "Gestreift"
		_:
			return "Getroffen"

func _apply_stat_changes(attacker: Dictionary, defender: Dictionary, move: MoveData) -> void:
	var changes = [
		[attacker, "attack_stage", move.UserAttackChange, "ATK"],
		[attacker, "defense_stage", move.UserDefenseChange, "DEF"],
		[attacker, "speed_stage", move.UserSpeedChange, "Initiative"],
		[defender, "attack_stage", move.TargetAttackChange, "ATK"],
		[defender, "defense_stage", move.TargetDefenseChange, "DEF"],
		[defender, "speed_stage", move.TargetSpeedChange, "Initiative"],
	]
	for change in changes:
		if change[2] == 0:
			continue
		var target: Dictionary = change[0]
		target[change[1]] = DamageCalculator.modify_stat_stage(target.get(change[1], 0), change[2])
		_log("  %s: %s %s" % [target["name"], change[3], "steigt" if change[2] > 0 else "sinkt"])

func _check_end() -> bool:
	if enemy["current_hp"] <= 0:
		_finish_battle("Gewonnen!", "%s ist besiegt!" % enemy["name"])
	elif player["current_hp"] <= 0:
		_finish_battle("Verloren...", "%s ist besiegt!" % player["name"])
	return is_over

func _finish_battle(title: String, message: String) -> void:
	is_over = true
	command.cancel()
	_log("=== " + message + " ===")
	hint_label.text = ""
	result_label.text = title
	result_panel.visible = true
	result_panel.get_child(0).get_child(1).grab_focus()

# =========================
# ANIMATION
# =========================

## Platzhalter-Animation: Sprung auf den Gegner, Aufprall genau beim ersten Zeitpunkt,
## danach für jeden weiteren Zeitpunkt kurz ausholen und wieder zuschlagen.
## Wenn es echte Animationen gibt, ersetzt die Animation das hier und TimingHits wird an sie angepasst.
func _attack_animation(sprite: Sprite2D, from: Vector2, target: Vector2, hit_times: Array[float]) -> Tween:
	var hit_pos = target.lerp(from, 0.18)
	var windup_pos = target.lerp(from, 0.35)
	var tween = create_tween()
	tween.tween_method(
		func(t: float): sprite.position = from.lerp(hit_pos, t) + Vector2(0, -sin(t * PI) * 90.0),
		0.0, 1.0, hit_times[0]
	)
	for i in range(1, hit_times.size()):
		var gap = hit_times[i] - hit_times[i - 1]
		tween.tween_property(sprite, "position", windup_pos, gap * 0.6).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "position", hit_pos, gap * 0.4).set_ease(Tween.EASE_IN)
	return tween

## Platzhalter-Animation für Status-Attacken: auf der Stelle hüpfen, Landung = Zeitpunkt
func _status_animation(sprite: Sprite2D, home: Vector2, hit_times: Array[float]) -> Tween:
	var tween = create_tween()
	var previous = 0.0
	for time in hit_times:
		var duration = time - previous
		tween.tween_property(sprite, "position:y", home.y - 50.0, duration * 0.5).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "position:y", home.y, duration * 0.5).set_ease(Tween.EASE_IN)
		previous = time
	return tween

func _shake(sprite: Sprite2D) -> void:
	var home = player_home if sprite == player_sprite else enemy_home
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(sprite, "position:x", home.x + 10.0, 0.04)
		tween.tween_property(sprite, "position:x", home.x - 10.0, 0.04)
	tween.tween_property(sprite, "position:x", home.x, 0.04)

func _dodge(sprite: Sprite2D) -> void:
	var home = player_home if sprite == player_sprite else enemy_home
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", home.y - 70.0, 0.15)
	tween.tween_property(sprite, "position:y", home.y, 0.2)
