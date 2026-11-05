extends CharacterBody2D

## Mini-Spielfigur nur zum Testen von Maps.
## Der richtige Spieler kommt aus dem Tutorial "Spieler und NPCs".

@export var speed := 80.0

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	move_and_slide()
