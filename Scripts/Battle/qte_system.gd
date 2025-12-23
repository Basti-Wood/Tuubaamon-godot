extends Node
class_name QTESystem

## Quick Time Event System for battle actions
## Handles different types of timing-based mini-games to enhance combat

# =========================
# SIGNALS
# =========================

signal qte_started(qte_type: int)
signal qte_completed(success_level: float)  # 0.0 = fail, 0.5 = partial, 1.0 = perfect
signal qte_failed()
signal qte_progress_updated(progress: float)

# =========================
# ENUMS
# =========================

enum QTEResult {
	FAILURE,   # 0.0 - 0.3
	PARTIAL,   # 0.3 - 0.8
	SUCCESS,   # 0.8 - 1.0
	PERFECT    # Exactly 1.0
}

enum QTEType {
	NONE,
	BUTTON_MASH,
	TIMED_PRESS,
	SEQUENCE,
	HOLD,
	RHYTHM
}

# =========================
# STATE
# =========================

var is_active: bool = false
var current_qte_type: QTEType = QTEType.NONE
var qte_time_remaining: float = 0.0
var qte_max_time: float = 1.0
var qte_difficulty: int = 3

# Button Mash
var button_mash_count: int = 0
var button_mash_required: int = 10

# Timed Press
var timed_press_perfect_time: float = 0.0
var timed_press_tolerance: float = 0.1

# Sequence
var button_sequence: Array[String] = []
var sequence_index: int = 0

# Hold
var hold_duration: float = 0.0
var hold_required: float = 1.0
var is_holding: bool = false

# Rhythm
var rhythm_beats: Array[float] = []
var rhythm_index: int = 0
var rhythm_tolerance: float = 0.15

# Results
var success_level: float = 0.0

# =========================
# INITIALIZATION
# =========================

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if not is_active:
		return
	
	qte_time_remaining -= delta
	
	if qte_time_remaining <= 0.0:
		_complete_qte(false)
		return
	
	match current_qte_type:
		QTEType.TIMED_PRESS:
			_process_timed_press(delta)
		QTEType.HOLD:
			_process_hold(delta)
		QTEType.RHYTHM:
			_process_rhythm(delta)

# =========================
# QTE INITIATION
# =========================

func start_qte(qte_type: QTEType, time_window: float, difficulty: int) -> void:
	if is_active:
		push_warning("QTE already active!")
		return
	
	is_active = true
	current_qte_type = qte_type
	qte_max_time = time_window
	qte_time_remaining = time_window
	qte_difficulty = difficulty
	success_level = 0.0
	
	_initialize_qte_type(qte_type, difficulty)
	
	set_process(true)
	qte_started.emit(qte_type)

func cancel_qte() -> void:
	is_active = false
	set_process(false)
	success_level = 0.0

# =========================
# QTE TYPE INITIALIZATION
# =========================

func _initialize_qte_type(qte_type: QTEType, difficulty: int) -> void:
	match qte_type:
		QTEType.BUTTON_MASH:
			button_mash_count = 0
			button_mash_required = 5 + (difficulty * 3)  # 8, 11, 14, etc.
		
		QTEType.TIMED_PRESS:
			timed_press_perfect_time = qte_max_time * 0.5
			timed_press_tolerance = 0.2 - (difficulty * 0.02)  # Harder = smaller window
		
		QTEType.SEQUENCE:
			sequence_index = 0
			button_sequence = _generate_button_sequence(difficulty)
		
		QTEType.HOLD:
			hold_duration = 0.0
			hold_required = qte_max_time * 0.7
			is_holding = false
		
		QTEType.RHYTHM:
			rhythm_index = 0
			rhythm_beats = _generate_rhythm_beats(difficulty, qte_max_time)
			rhythm_tolerance = 0.2 - (difficulty * 0.02)

# =========================
# INPUT HANDLING
# =========================

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	
	match current_qte_type:
		QTEType.BUTTON_MASH:
			_handle_button_mash(event)
		QTEType.TIMED_PRESS:
			_handle_timed_press(event)
		QTEType.SEQUENCE:
			_handle_sequence(event)
		QTEType.HOLD:
			_handle_hold(event)
		QTEType.RHYTHM:
			_handle_rhythm(event)

# =========================
# BUTTON MASH
# =========================

func _handle_button_mash(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		button_mash_count += 1
		success_level = clampf(float(button_mash_count) / float(button_mash_required), 0.0, 1.0)
		qte_progress_updated.emit(success_level)
		
		if button_mash_count >= button_mash_required:
			_complete_qte(true)

# =========================
# TIMED PRESS
# =========================

func _process_timed_press(delta: float) -> void:
	var time_elapsed = qte_max_time - qte_time_remaining
	qte_progress_updated.emit(time_elapsed / qte_max_time)

func _handle_timed_press(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var time_elapsed = qte_max_time - qte_time_remaining
		var time_diff = abs(time_elapsed - timed_press_perfect_time)
		
		if time_diff <= timed_press_tolerance:
			# Success - calculate how close to perfect
			success_level = 1.0 - (time_diff / timed_press_tolerance) * 0.2
			_complete_qte(true)
		else:
			# Failed timing
			success_level = 0.0
			_complete_qte(false)

# =========================
# SEQUENCE
# =========================

func _generate_button_sequence(difficulty: int) -> Array[String]:
	var actions = ["ui_up", "ui_down", "ui_left", "ui_right"]
	var sequence: Array[String] = []
	var length = 3 + difficulty  # 4, 5, 6, etc.
	
	for i in range(length):
		sequence.append(actions[randi() % actions.size()])
	
	return sequence

func _handle_sequence(event: InputEvent) -> void:
	if sequence_index >= button_sequence.size():
		return
	
	var expected_action = button_sequence[sequence_index]
	
	if event.is_action_pressed(expected_action):
		sequence_index += 1
		success_level = float(sequence_index) / float(button_sequence.size())
		qte_progress_updated.emit(success_level)
		
		if sequence_index >= button_sequence.size():
			_complete_qte(true)
	elif event is InputEventKey and event.pressed:
		# Wrong button pressed
		_complete_qte(false)

# =========================
# HOLD
# =========================

func _handle_hold(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		is_holding = true
	elif event.is_action_released("ui_accept"):
		is_holding = false

func _process_hold(delta: float) -> void:
	if is_holding:
		hold_duration += delta
		success_level = clampf(hold_duration / hold_required, 0.0, 1.0)
		qte_progress_updated.emit(success_level)
		
		if hold_duration >= hold_required:
			_complete_qte(true)

# =========================
# RHYTHM
# =========================

func _generate_rhythm_beats(difficulty: int, total_time: float) -> Array[float]:
	var beats: Array[float] = []
	var num_beats = 2 + difficulty  # 3, 4, 5, etc.
	var interval = total_time / (num_beats + 1)
	
	for i in range(num_beats):
		beats.append((i + 1) * interval)
	
	return beats

func _process_rhythm(delta: float) -> void:
	var time_elapsed = qte_max_time - qte_time_remaining
	
	# Show which beat we're waiting for
	if rhythm_index < rhythm_beats.size():
		var progress = time_elapsed / qte_max_time
		qte_progress_updated.emit(progress)

func _handle_rhythm(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return
	
	if rhythm_index >= rhythm_beats.size():
		return
	
	var time_elapsed = qte_max_time - qte_time_remaining
	var expected_time = rhythm_beats[rhythm_index]
	var time_diff = abs(time_elapsed - expected_time)
	
	if time_diff <= rhythm_tolerance:
		# Good hit
		rhythm_index += 1
		var hit_quality = 1.0 - (time_diff / rhythm_tolerance) * 0.3
		success_level += hit_quality / float(rhythm_beats.size())
		
		if rhythm_index >= rhythm_beats.size():
			success_level = clampf(success_level, 0.0, 1.0)
			_complete_qte(true)
	else:
		# Missed the beat
		_complete_qte(false)

# =========================
# COMPLETION
# =========================

func _complete_qte(succeeded: bool) -> void:
	is_active = false
	set_process(false)
	
	if not succeeded:
		success_level = 0.0
		qte_failed.emit()
	
	qte_completed.emit(success_level)

# =========================
# RESULT INTERPRETATION
# =========================

func get_qte_result() -> QTEResult:
	if success_level >= 1.0:
		return QTEResult.PERFECT
	elif success_level >= 0.8:
		return QTEResult.SUCCESS
	elif success_level >= 0.3:
		return QTEResult.PARTIAL
	else:
		return QTEResult.FAILURE

func get_damage_multiplier(move_data: MoveData) -> float:
	var result = get_qte_result()
	
	match result:
		QTEResult.PERFECT, QTEResult.SUCCESS:
			return move_data.QTESuccessMultiplier
		QTEResult.PARTIAL:
			return move_data.QTEPartialMultiplier
		QTEResult.FAILURE:
			return move_data.QTEFailureMultiplier
		_:
			return 1.0

# =========================
# HELPERS
# =========================

func get_progress() -> float:
	return success_level

func get_time_remaining() -> float:
	return qte_time_remaining

func get_current_button_sequence() -> Array[String]:
	return button_sequence

func get_sequence_progress() -> int:
	return sequence_index
