extends CharacterBody3D

## PLATZHALTER - Spielfigur in der Overworld (2.5D).
## Aufbau der Szene Szene/Overworld/player.tscn:
##   Player (CharacterBody3D, dieses Skript)
##   ├── Sprite3D / AnimatedSprite3D   billboard = Y-Billboard, damit die 2D-Figur immer zur Kamera schaut
##   ├── CollisionShape3D              Kapsel
##   ├── InteractRay (RayCast3D)       zeigt in Blickrichtung, für NPCs/Schilder/VM-Hindernisse
##   └── (die Kamera hängt NICHT hier dran, siehe overworld_camera.gd)

@export var move_speed: float = 4.0

# TODO: var facing := Vector3.FORWARD
# TODO: var can_move := true      # false während Dialog, Menü oder Kampf-Übergang

func _physics_process(delta: float) -> void:
	# TODO:
	# var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# var direction := Vector3(input.x, 0, input.y)      # Kamera schaut schräg von oben, also x/z
	# velocity.x = direction.x * move_speed
	# velocity.z = direction.z * move_speed
	# Schwerkraft auf velocity.y, falls es Höhenunterschiede gibt
	# move_and_slide()
	# Sprite-Animation je nach Richtung wählen (links/rechts per flip_h spiegeln)
	pass

func _unhandled_input(event: InputEvent) -> void:
	# TODO:
	# if event.is_action_pressed("interact") and InteractRay trifft etwas mit interact():
	#     ziel.interact(self)
	# if event.is_action_pressed("pause"): Pausemenü öffnen
	pass
