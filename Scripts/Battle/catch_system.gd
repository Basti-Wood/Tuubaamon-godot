extends RefCounted

## PLATZHALTER - Monster mit Schmuck/Amulett fangen.

func try_catch(target, amulet) -> bool:
	# TODO:
	# hp_factor = 1.0 - (target.current_hp / target.get_max_hp())     # weniger KP = leichter
	# chance = target.species.catch_rate / 100.0 * amulet.catch_bonus * (0.5 + hp_factor)
	# Status (Schlaf, Paralyse) erhöht die Chance
	# Optional: ein ActionCommand beim Werfen, gutes Timing gibt einen Bonus
	# return randf() < chance
	return false

func add_to_team(monster) -> void:
	# TODO: wenn GameState.party.size() < 6 -> ins Team, sonst in die Box
	pass
