extends Area3D

## PLATZHALTER - Bereich mit hohem Gras / Höhle, in dem wilde Monster auftauchen.
## Als Kind der Map-Szene anlegen, CollisionShape3D über das Gras ziehen.

@export var encounter_table: Resource      # TODO: Typ auf EncounterTable ändern
@export_range(0.0, 1.0) var chance_per_step: float = 0.08

# TODO: var _player_inside := false
# TODO: var _distance_walked := 0.0

func _ready() -> void:
	# TODO: body_entered / body_exited verbinden und merken, ob der Spieler drin ist
	pass

func _physics_process(delta: float) -> void:
	# TODO:
	# if _player_inside and Spieler bewegt sich:
	#     _distance_walked += gelaufene Strecke
	#     if _distance_walked >= 1.0 (ein "Schritt"):
	#         _distance_walked = 0
	#         if randf() < chance_per_step:
	#             var wild = encounter_table.roll()
	#             SceneSwitcher.start_battle([MonsterInstance aus wild])
	pass
