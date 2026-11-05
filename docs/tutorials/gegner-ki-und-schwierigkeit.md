# Gegner-KI und Schwierigkeitsgrade

Brainstorm: KI-Stufen Dumm (wilde Monster), Mittel (Trainer, 50/50), Klug (Arenen, Ass-Trainer, Top 5, Ömer). Wesen aggressiv/passiv. Schwierigkeitsgrade Leicht bis Challenge. Gegner haben auch Timing-Stufen („Präzision“).

## 1. KI-Stufen

Ersetzt den Platzhalter `Scripts/Battle/enemy_ai.gd`. Die Bewertung ist absichtlich simpel: erwarteter Schaden = Stärke × Typ-Effektivität. Passe `_score()` an eure echten Funktionen an.

```gdscript
extends RefCounted
class_name EnemyBrain

enum Level { DUMM, MITTEL, KLUG }
enum Wesen { AGGRESSIV, PASSIV }

var level := Level.DUMM
var wesen := Wesen.AGGRESSIV

## moves: Array von MoveData, defender: das Ziel.
func choose_move(moves: Array, defender) -> Resource:
	if moves.is_empty():
		return null
	var smart := level == Level.KLUG or (level == Level.MITTEL and randf() < 0.5)
	if not smart:
		return moves.pick_random()
	var best: Resource = moves[0]
	for m in moves:
		if _score(m, defender) > _score(best, defender):
			best = m
	return best

func _score(move, defender) -> float:
	var power: float = move.get("power") if move.get("power") != null else 0.0
	# TODO: power *= TypeChart.get_effectiveness(move.type, defender.types)
	if wesen == Wesen.PASSIV and power == 0.0:
		return 999.0  # Statusattacken zuerst
	return power

## Timing-Stufe des Gegners: 0 = schlecht ... 4 = exzellent.
func roll_timing_tier() -> int:
	var chances := {Level.DUMM: [30, 40, 20, 8, 2], Level.MITTEL: [10, 25, 35, 20, 10], Level.KLUG: [2, 8, 30, 35, 25]}
	var roll := randi() % 100
	var sum := 0
	for tier in 5:
		sum += chances[level][tier]
		if roll < sum:
			return tier
	return 4
```

Klug-KI kann später mehr (Reaktion aufsparen, Spieler gezielt angreifen). Das kommt als weitere `if`s in `choose_move`.

## 2. Schwierigkeitsgrad

Eine Tabelle, welche Stufe wer bekommt. Speichere `difficulty` im ConfigManager oder GameState.

```gdscript
extends RefCounted
class_name Difficulty

enum Mode { LEICHT, NORMAL, SCHWER, CHALLENGE }
enum Who { WILD, TRAINER, ELITE }

const TABLE := {
	Mode.LEICHT:    [EnemyBrain.Level.DUMM,   EnemyBrain.Level.DUMM,   EnemyBrain.Level.MITTEL],
	Mode.NORMAL:    [EnemyBrain.Level.DUMM,   EnemyBrain.Level.MITTEL, EnemyBrain.Level.KLUG],
	Mode.SCHWER:    [EnemyBrain.Level.MITTEL, EnemyBrain.Level.KLUG,   EnemyBrain.Level.KLUG],
	Mode.CHALLENGE: [EnemyBrain.Level.KLUG,   EnemyBrain.Level.KLUG,   EnemyBrain.Level.KLUG],
}

static func brain_for(mode: Mode, who: Who) -> EnemyBrain:
	var b := EnemyBrain.new()
	b.level = TABLE[mode][who]
	return b
```

Im Kampf: `var ai := Difficulty.brain_for(mode, Difficulty.Who.TRAINER)` und `ai.wesen` vom Trainer übernehmen (z. B. `@export var wesen` am NPC).
