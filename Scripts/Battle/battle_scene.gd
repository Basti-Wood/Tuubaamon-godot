extends CanvasLayer

## Die Kampfszene (2D). Der SceneSwitcher öffnet sie und ruft setup() auf.
## Eine Runde: Spieler wählt -> Angriffe nach Priorität und Initiative -> K.O. prüfen.
## Jeder Angriff hat ein Timing (ActionCommand, Zeitpunkte aus MoveData.TimingHits):
##   Spieler greift an -> im Moment des Aufpralls drücken = mehr Schaden
##   Gegner greift an  -> im Moment des Aufpralls drücken = blocken / ausweichen

signal battle_finished(result: String)    # "win", "lose", "caught", "fled"

@export var catch_amulet: AmuletData                         # Rohling zum Bannen (TODO: aus dem Inventar)
@export_range(0.0, 1.0) var enemy_precision: float = 0.4    # Timing des Gegners (KI-Stufe)

@onready var action_command: ActionCommand = $ActionCommand
@onready var timing_ring: TimingRing = $TimingRing
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var enemy_sprite: Sprite2D = $EnemySprite
@onready var player_label: Label = $PlayerLabel
@onready var enemy_label: Label = $EnemyLabel
@onready var player_hp: ProgressBar = $PlayerHP
@onready var enemy_hp: ProgressBar = $EnemyHP
@onready var info: Label = $Info
@onready var buttons: HBoxContainer = $Buttons

var player_team: Array
var enemy_team: Array
var is_trainer := false
var player_mon: MonsterInstance
var enemy_mon: MonsterInstance

func _ready() -> void:
	timing_ring.command = action_command
	action_command.hit_judged.connect(func(_i, tier, _o): timing_ring.flash(Color.GOLD if tier >= ActionCommand.Tier.GUT else Color.GRAY))

func setup(p_team: Array, e_team: Array, trainer: bool) -> void:
	player_team = p_team
	enemy_team = e_team
	is_trainer = trainer
	enemy_mon = _next_alive(enemy_team)
	player_mon = _next_alive(player_team)
	if player_mon == null:
		# TODO: Spieler kämpft selbst, wenn kein Monster da ist (design/spielmechaniken.md, Kap. 3)
		battle_finished.emit("lose")
		return
	_refresh()
	_say("Ein wildes %s erscheint!" % enemy_mon.get_display_name())
	_open_menu()

# =========================
# MENÜ
# =========================

func _open_menu() -> void:
	for child in buttons.get_children():
		buttons.remove_child(child)
		child.queue_free()
	for move in _moves_of(player_mon):
		_add_button(move.MoveName, _on_move_chosen.bind(move))
	if not is_trainer:
		_add_button("Bannen", _on_catch_chosen)
		_add_button("Fliehen", func(): battle_finished.emit("fled"))
	buttons.show()
	buttons.get_child(0).grab_focus()

func _add_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	buttons.add_child(button)

# =========================
# RUNDE
# =========================

func _on_move_chosen(move: MoveData) -> void:
	buttons.hide()
	var enemy_move := EnemyAI.choose_move(_moves_of(enemy_mon))
	var player_first := move.Priority > enemy_move.Priority or (move.Priority == enemy_move.Priority \
			and player_mon.get_stat("speed") >= enemy_mon.get_stat("speed"))

	if player_first:
		await _attack(player_mon, enemy_mon, move, true)
		if not enemy_mon.is_fainted():
			await _attack(enemy_mon, player_mon, enemy_move, false)
	else:
		await _attack(enemy_mon, player_mon, enemy_move, false)
		if not player_mon.is_fainted():
			await _attack(player_mon, enemy_mon, move, true)
	_end_of_turn()

func _attack(attacker: MonsterInstance, defender: MonsterInstance, move: MoveData, by_player: bool) -> void:
	var sprite := player_sprite if by_player else enemy_sprite
	var target := enemy_sprite if by_player else player_sprite
	var hits := move.get_timing_hits()
	_say("%s setzt %s ein!  %s" % [attacker.get_display_name(), move.MoveName,
			"Drück im Moment des Aufpralls!" if by_player else "Drück beim Aufprall zum Blocken!"])

	# Anlauf: der Angreifer kommt genau zum ersten Aufprall beim Ziel an
	var start := sprite.position
	timing_ring.position = target.position
	create_tween().tween_property(sprite, "position", target.position.lerp(start, 0.3), hits[0]) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	action_command.start_for_move(move)
	var tier: int = await action_command.finished
	create_tween().tween_property(sprite, "position", start, 0.25)

	var multiplier: float
	if by_player:
		multiplier = ActionCommand.ATTACK_MULTIPLIERS[tier]
	else:
		var enemy_tier := EnemyAI.roll_timing_tier(enemy_precision)
		multiplier = ActionCommand.ATTACK_MULTIPLIERS[enemy_tier] * ActionCommand.DEFENSE_MULTIPLIERS[tier]

	# TODO: Genauigkeit, Krit (Glück), Mehrfachtreffer einzeln werten (IsMultiHit)
	var result := DamageCalculator.calculate_damage(_battle_data(attacker), _battle_data(defender), move, multiplier)
	var damage: int = 0 if multiplier <= 0.0 else result.damage   # exzellent geblockt = ausgewichen
	defender.current_hp = maxi(defender.current_hp - damage, 0)
	_refresh()
	_say("%s  %d Schaden. %s" % [ActionCommand.TIER_NAMES[tier], damage, result.effectiveness_text])
	await _wait(1.2)

func _end_of_turn() -> void:
	if enemy_mon.is_fainted():
		# TODO: EP verteilen (MonsterInstance.gain_exp)
		_say("%s ist besiegt!" % enemy_mon.get_display_name())
		await _wait(1.2)
		enemy_mon = _next_alive(enemy_team)
		if enemy_mon == null:
			battle_finished.emit("win")
			return
		_refresh()

	if player_mon.is_fainted():
		_say("%s ist K.O.!" % player_mon.get_display_name())
		await _wait(1.2)
		player_mon = _next_alive(player_team)
		if player_mon == null:
			battle_finished.emit("lose")
			return
		_refresh()
		_say("Los, %s!" % player_mon.get_display_name())
	_open_menu()

# =========================
# BANNEN (FANGEN)
# =========================

func _on_catch_chosen() -> void:
	buttons.hide()
	if catch_amulet == null:
		_say("Du hast keinen Rohling!")
		await _wait(1.2)
		_open_menu()
		return

	_say("Du hältst den %s hoch ... drück, wenn sich der Ring schließt!" % catch_amulet.ItemName)
	timing_ring.position = enemy_sprite.position
	action_command.start(1.0)
	var tier: int = await action_command.finished

	if CatchSystem.try_catch(enemy_mon, catch_amulet, tier):
		var place := CatchSystem.add_to_team(enemy_mon, catch_amulet)
		enemy_sprite.hide()
		_say("%s! %s wurde gebannt! (%s)" % [ActionCommand.TIER_NAMES[tier], enemy_mon.get_display_name(),
				"ins Team" if place == "party" else "in die Box"])
		await _wait(1.5)
		battle_finished.emit("caught")
		return

	_say("%s ... %s hat sich befreit!" % [ActionCommand.TIER_NAMES[tier], enemy_mon.get_display_name()])
	await _wait(1.2)
	await _attack(enemy_mon, player_mon, EnemyAI.choose_move(_moves_of(enemy_mon)), false)
	_end_of_turn()

# =========================
# HILFSFUNKTIONEN
# =========================

func _refresh() -> void:
	player_sprite.texture = player_mon.species.sprite
	enemy_sprite.texture = enemy_mon.species.sprite
	player_label.text = "%s  Lv. %d" % [player_mon.get_display_name(), player_mon.level]
	enemy_label.text = "%s  Lv. %d" % [enemy_mon.get_display_name(), enemy_mon.level]
	player_hp.max_value = player_mon.get_max_hp()
	player_hp.value = player_mon.current_hp
	enemy_hp.max_value = enemy_mon.get_max_hp()
	enemy_hp.value = enemy_mon.current_hp

func _say(text: String) -> void:
	info.text = text

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _next_alive(team: Array) -> MonsterInstance:
	for monster in team:
		if not monster.is_fainted():
			return monster
	return null

## Attacken des Monsters. Hat es keine, gibt es "Rempler", damit der Kampf trotzdem läuft.
func _moves_of(monster: MonsterInstance) -> Array[MoveData]:
	if not monster.moves.is_empty():
		return monster.moves
	var tackle := MoveData.new()
	tackle.MoveName = "Rempler"
	tackle.MoveType = Enums.Type.NORMAL
	tackle.AttackType = Enums.AttackType.PHYSICAL
	tackle.Damage = 40
	var fallback: Array[MoveData] = [tackle]
	return fallback

## Werte im Format, das der DamageCalculator erwartet
func _battle_data(monster: MonsterInstance) -> Dictionary:
	return {
		"level": monster.level,
		"types": [monster.species.primary_type, monster.species.secondary_type],
		"attack": monster.get_stat("attack"),
		"defense": monster.get_stat("defense"),
		"special_attack": monster.get_stat("special_attack"),
		"special_defense": monster.get_stat("special_defense"),
	}
