extends Resource
class_name MoveData

@export var MoveName: String
@export_multiline var Description: String

@export var MoveType: Enums.Type
@export var AttackType: Enums.AttackType
@export var Damage: int
@export_range(0, 100) var Accuracy: int = 100
@export var MaxPP: int = 10
@export var Target: Enums.Target = Enums.Target.ENEMY_SINGLE
@export_range(-1, 1) var Priority: int = 0

@export var InflictsStatus: bool = false
@export var status_effect: Resource
@export_range(0, 100) var StatusChance: int = 0

@export var Contact: bool = true

# =========================
# TIMING (ACTION COMMAND)
# =========================
## Jede Attacke hat ein Timing (5 Stufen, Scripts/Battle/action_command.gd).
## Hier stellst du ein, WANN gedrückt werden muss, passend zur Animation der Attacke.
@export_group("Timing")

## Zeitpunkte der Treffer in Sekunden ab Start der Animation, ein Eintrag = ein Tastendruck.
## Beispiel: [0.8] = ein Aufprall nach 0,8 s. [0.5, 0.9, 1.2] = drei Drücke.
## Mehrfachtreffer (IsMultiHit): jeder Eintrag ist ein eigener Treffer mit eigener Stufe.
## Sonst wird der Durchschnitt aller Drücke für den einen Treffer genommen.
@export var TimingHits: Array[float] = [0.8]

## Größe der Zeitfenster nur für diese Attacke: > 1 = leichter, < 1 = schwerer
@export_range(0.25, 3.0) var TimingWindowScale: float = 1.0

# =========================
# QUICK TIME EVENT (QTE), ALT
# =========================
## Altes System, wird nur noch vom DEBUG-Kampf benutzt. Das neue Timing steht oben in "Timing".
@export_group("Quick Time Event (alt)")
@export var HasQTE: bool = false

@export var QTEType: Enums.QTEType = Enums.QTEType.NONE

# QTE difficulty settings
@export_range(0.1, 3.0) var QTETimeWindow: float = 1.0   # Time to complete QTE
@export_range(1, 10) var QTEDifficulty: int = 3          # How hard the QTE is

# QTE rewards
@export_range(1.0, 3.0) var QTESuccessMultiplier: float = 1.5   # Damage/effect multiplier on perfect
@export_range(1.0, 2.0) var QTEPartialMultiplier: float = 1.2   # Multiplier on partial success
@export_range(0.0, 1.0) var QTEFailureMultiplier: float = 0.75  # Multiplier on failure

# =========================
# ADDITIONAL EFFECTS
# =========================
@export_group("Special Effects")
@export var Recoil: float = 0.0          # Percentage of damage dealt to user
@export var Drain: float = 0.0           # Percentage of damage healed to user
@export var Flinch: int = 0              # Chance to make target flinch
@export var CritRateBonus: int = 0       # Additional crit chance

# Stat changes (stages from -6 to +6)
@export var UserAttackChange: int = 0
@export var UserDefenseChange: int = 0
@export var UserSpeedChange: int = 0
@export var TargetAttackChange: int = 0
@export var TargetDefenseChange: int = 0
@export var TargetSpeedChange: int = 0

# Multi-hit moves
@export var IsMultiHit: bool = false
@export var MinHits: int = 1
@export var MaxHits: int = 1

@export_multiline var BattleText: String  # Custom text when move is used

# =========================
# HELPERS
# =========================

## Trefferzeitpunkte sortiert und ohne negative Werte. Leer = ein Treffer nach 0,8 s.
func get_timing_hits() -> Array[float]:
	var hits: Array[float] = []
	for time in TimingHits:
		hits.append(maxf(time, 0.05))
	if hits.is_empty():
		hits.append(0.8)
	hits.sort()
	return hits
