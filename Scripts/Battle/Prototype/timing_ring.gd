extends Node2D
class_name TimingRing

## Zeigt ein ActionCommand an: Ein Ring zieht sich zusammen und berührt
## den festen Kreis genau im Moment des Aufpralls.

var command: ActionCommand
var radius: float = 70.0

var _flash_color: Color = Color.TRANSPARENT
var _flash_alpha: float = 0.0

func flash(color: Color) -> void:
	_flash_color = color
	_flash_alpha = 1.0

func _process(delta: float) -> void:
	_flash_alpha = maxf(0.0, _flash_alpha - delta * 2.0)
	queue_redraw()

func _draw() -> void:
	if command and command.is_active:
		var progress = command.get_progress()
		var moving_radius = radius * maxf(0.3, 3.0 - 2.0 * progress)
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(1, 1, 1, 0.85), 5.0)
		draw_arc(Vector2.ZERO, moving_radius, 0.0, TAU, 64, Color(1.0, 0.8, 0.2), 4.0)
	elif _flash_alpha > 0.0:
		var color = _flash_color
		color.a = _flash_alpha
		draw_arc(Vector2.ZERO, radius * (1.0 + (1.0 - _flash_alpha) * 0.4), 0.0, TAU, 64, color, 8.0)
