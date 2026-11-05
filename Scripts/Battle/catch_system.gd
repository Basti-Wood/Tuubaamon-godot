extends RefCounted
class_name CatchSystem

## Monster mit Schmuck/Amulett bannen (design/spielmechaniken.md, Kap. 1.2).
## Chance = Fangrate × HP-Faktor × Schmuck-Qualität × Timing-Stufe

# Bonus je Timing-Stufe (schlecht .. exzellent)
const TIMING_BONUS: Array[float] = [0.5, 0.8, 1.0, 1.2, 1.5]

static func get_chance(target: MonsterInstance, amulet: AmuletData, tier: int) -> float:
	var hp_factor := 1.5 - float(target.current_hp) / target.get_max_hp()   # volle KP = 0.5, fast leer = 1.5
	var chance := target.species.catch_rate / 100.0 * amulet.catch_bonus * hp_factor * TIMING_BONUS[tier]
	# TODO: Status (Schlaf, Paralyse) erhöht die Chance
	return clampf(chance, 0.0, 1.0)

static func try_catch(target: MonsterInstance, amulet: AmuletData, tier: int) -> bool:
	return randf() < get_chance(target, amulet, tier)

## Gibt dem Monster sein Schmuckstück und packt es ins Team (max. 6) oder in die Box.
static func add_to_team(monster: MonsterInstance, amulet: AmuletData) -> String:
	monster.amulet = amulet.duplicate() as AmuletData   # ein Schmuckstück = ein Monster
	# TODO: den benutzten Rohling aus dem Inventar entfernen
	if GameState.party.size() < GameState.MAX_PARTY:
		GameState.party.append(monster)
		return "party"
	GameState.box.append(monster)
	return "box"
