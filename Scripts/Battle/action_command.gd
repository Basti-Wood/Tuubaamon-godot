extends Node
class_name ActionCommand

## Action Command im Mario & Luigi Stil: ein Tastendruck im Moment des Aufpralls.
## Bewertet den Druck in 5 Stufen (siehe design/spielmechaniken.md, Kap. 4.3).
## Wird für Angriff (mehr Schaden) und Verteidigung (weniger Schaden) benutzt.
## Eine Attacke kann mehrere Aufpralle haben (MoveData.TimingHits), jeder wird einzeln bewertet.

# =========================
# SIGNALS
# =========================

signal hit_judged(index: int, tier: int, offset: float)  # nach jedem einzelnen Aufprall
signal finished(tier: int)                              # nach dem letzten Aufprall, Durchschnitt

# =========================
# TIERS
# =========================

enum Tier {
	SCHLECHT,
	OKAY,
	GUT,
	SEHR_GUT,
	EXZELLENT
}

const TIER_NAMES: Array[String] = ["Schlecht", "Okay", "Gut", "Sehr gut!", "Exzellent!!"]

# Schaden des Angreifers je Stufe (Vorschlag aus dem Design-Dokument)
const ATTACK_MULTIPLIERS: Array[float] = [0.5, 0.8, 1.0, 1.15, 1.3]

# Erlittener Schaden des Verteidigers je Stufe (exzellent = komplett ausgewichen)
const DEFENSE_MULTIPLIERS: Array[float] = [1.0, 0.85, 0.7, 0.5, 0.0]

# Maximaler Abstand zum Aufprall in Sekunden: exzellent, sehr gut, gut, okay.
# Alles darüber, zu früh gedrückt oder gar nicht gedrückt = schlecht.
const TIER_WINDOWS: Array[float] = [0.04, 0.08, 0.13, 0.20]

# =========================
# SETTINGS
# =========================

@export var input_action: StringName = &"ui_accept"
@export_range(0.25, 3.0) var window_scale: float = 1.0  # > 1 = leichter, < 1 = schwerer
@export var auto_timing: bool = false                   # Barrierefreiheit: immer "gut"

# =========================
# STATE
# =========================

var is_active: bool = false
var impact_time: float = 1.0  # Zeitpunkt des aktuellen Aufpralls ab Start
var last_offset: float = 0.0  # Sekunden, negativ = zu früh, positiv = zu spät
var hit_times: Array[float] = []
var hit_tiers: Array[int] = []
var hit_offsets: Array[float] = []
var hit_index: int = 0
var _segment_start: float = 0.0  # vorheriger Aufprall (oder 0), für die Anzeige
var _move_scale: float = 1.0
var _start_usec: int = 0

# =========================
# PUBLIC API
# =========================

## Startet den Befehl mit einem Aufprall nach time_until_impact Sekunden.
func start(time_until_impact: float, move_scale: float = 1.0) -> void:
	start_hits([time_until_impact], move_scale)

## Startet den Befehl mit mehreren Aufprallen (Sekunden ab jetzt, z. B. MoveData.get_timing_hits()).
## move_scale ist das Zeitfenster der Attacke (MoveData.TimingWindowScale).
func start_for_move(move: MoveData) -> void:
	start_hits(move.get_timing_hits(), move.TimingWindowScale)

func start_hits(times: Array[float], move_scale: float = 1.0) -> void:
	if is_active:
		push_warning("ActionCommand already active!")
		return

	hit_times.clear()
	for time in times:
		hit_times.append(maxf(time, 0.05))
	if hit_times.is_empty():
		hit_times.append(1.0)
	hit_times.sort()

	hit_tiers.clear()
	hit_offsets.clear()
	hit_index = 0
	_segment_start = 0.0
	impact_time = hit_times[0]
	_move_scale = move_scale
	last_offset = 0.0
	_start_usec = Time.get_ticks_usec()
	is_active = true
	set_process(true)

func cancel() -> void:
	is_active = false
	set_process(false)

func get_elapsed() -> float:
	return (Time.get_ticks_usec() - _start_usec) / 1000000.0

## 0.0 = vorheriger Aufprall (oder Start), 1.0 = nächster Aufprall
func get_progress() -> float:
	return (get_elapsed() - _segment_start) / maxf(impact_time - _segment_start, 0.05)

## Gesamtes Zeitfenster-Maß: Einstellung (Barrierefreiheit) mal Attacke
func get_window_scale() -> float:
	return window_scale * _move_scale

## Durchschnittlicher Angriffs-Multiplikator aller bisher bewerteten Aufpralle
func get_average_attack_multiplier() -> float:
	return average_multiplier(hit_tiers, ATTACK_MULTIPLIERS)

static func average_multiplier(tiers: Array[int], multipliers: Array[float]) -> float:
	if tiers.is_empty():
		return 1.0
	var total = 0.0
	for tier in tiers:
		total += multipliers[tier]
	return total / tiers.size()

static func average_tier(tiers: Array[int]) -> int:
	if tiers.is_empty():
		return Tier.SCHLECHT
	var total = 0
	for tier in tiers:
		total += tier
	return clampi(roundi(float(total) / tiers.size()), Tier.SCHLECHT, Tier.EXZELLENT)

static func tier_for_offset(offset: float, scale: float = 1.0) -> int:
	var distance = absf(offset)
	if distance <= TIER_WINDOWS[0] * scale:
		return Tier.EXZELLENT
	if distance <= TIER_WINDOWS[1] * scale:
		return Tier.SEHR_GUT
	if distance <= TIER_WINDOWS[2] * scale:
		return Tier.GUT
	if distance <= TIER_WINDOWS[3] * scale:
		return Tier.OKAY
	return Tier.SCHLECHT

## Timing-Stufe für Gegner. precision 0.0 = fast immer schlecht, 1.0 = fast immer exzellent.
## Arbeitsname "Präzision" (Design-Dokument Kap. 4.3 / 8).
static func roll_enemy_tier(precision: float) -> int:
	return clampi(roundi(randfn(clampf(precision, 0.0, 1.0) * 4.0, 0.9)), Tier.SCHLECHT, Tier.EXZELLENT)

# =========================
# INTERNAL
# =========================

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	if not is_active:
		return

	var elapsed = get_elapsed()

	if auto_timing and elapsed >= impact_time:
		_judge(Tier.GUT, 0.0)
	elif elapsed > impact_time + TIER_WINDOWS[3] * get_window_scale():
		_judge(Tier.SCHLECHT, elapsed - impact_time)

func _input(event: InputEvent) -> void:
	if not is_active or auto_timing:
		return

	if event.is_action_pressed(input_action):
		get_viewport().set_input_as_handled()
		# Nur der erste Druck pro Aufprall zählt, Spammen lohnt sich also nicht
		var offset = get_elapsed() - impact_time
		_judge(tier_for_offset(offset, get_window_scale()), offset)

## Bewertet den aktuellen Aufprall und geht zum nächsten weiter
func _judge(tier: int, offset: float) -> void:
	last_offset = offset
	hit_tiers.append(tier)
	hit_offsets.append(offset)
	var index = hit_index
	hit_index += 1

	if hit_index >= hit_times.size():
		is_active = false
		set_process(false)
	else:
		_segment_start = impact_time
		impact_time = hit_times[hit_index]

	hit_judged.emit(index, tier, offset)
	if not is_active:
		finished.emit(average_tier(hit_tiers))
