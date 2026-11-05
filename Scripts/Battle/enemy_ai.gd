extends RefCounted
class_name EnemyAI

## Gegner-KI: welche Attacke der Gegner wählt und wie gut er sein Timing trifft.

## Einfache Variante: zufällige Attacke.
## TODO: bessere Variante: Attacken nach erwartetem Schaden gewichten (TypeChart.get_effectiveness)
static func choose_move(moves: Array[MoveData]) -> MoveData:
	return moves.pick_random()

## Gegner treffen ihr Timing auch in 5 Stufen. precision kommt von der KI-Stufe (0.0 .. 1.0).
static func roll_timing_tier(precision: float) -> int:
	return ActionCommand.roll_enemy_tier(precision)
