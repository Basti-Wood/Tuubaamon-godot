extends Node
class_name ActionCommand

## Action Command im Mario & Luigi Stil: ein Tastendruck im Moment des Aufpralls.
## Bewertet den Druck in 5 Stufen (siehe design/spielmechaniken.md, Kap. 4.3).
## Wird für Angriff (mehr Schaden) und Verteidigung (weniger Schaden) benutzt.

# =========================
# SIGNALS
# =========================

signal finished(tier: int)

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
var impact_time: float = 1.0
var last_offset: float = 0.0  # Sekunden, negativ = zu früh, positiv = zu spät
var _start_usec: int = 0

# =========================
# PUBLIC API
# =========================

## Startet den Befehl. Der Aufprall passiert nach time_until_impact Sekunden.
func start(time_until_impact: float) -> void:
	if is_active:
		push_warning("ActionCommand already active!")
		return

	impact_time = maxf(time_until_impact, 0.05)
	last_offset = 0.0
	_start_usec = Time.get_ticks_usec()
	is_active = true
	set_process(true)

func cancel() -> void:
	is_active = false
	set_process(false)

func get_elapsed() -> float:
	return (Time.get_ticks_usec() - _start_usec) / 1000000.0

## 0.0 = gerade gestartet, 1.0 = Aufprall
func get_progress() -> float:
	return get_elapsed() / impact_time

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
		_finish(Tier.GUT, 0.0)
	elif elapsed > impact_time + TIER_WINDOWS[3] * window_scale:
		_finish(Tier.SCHLECHT, elapsed - impact_time)

func _input(event: InputEvent) -> void:
	if not is_active or auto_timing:
		return

	if event.is_action_pressed(input_action):
		get_viewport().set_input_as_handled()
		# Nur der erste Druck zählt, Spammen lohnt sich also nicht
		var offset = get_elapsed() - impact_time
		_finish(tier_for_offset(offset, window_scale), offset)

func _finish(tier: int, offset: float) -> void:
	is_active = false
	set_process(false)
	last_offset = offset
	finished.emit(tier)
