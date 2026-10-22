extends Resource
class_name EncounterTable

## PLATZHALTER - welche wilden Monster in einem Gebiet auftauchen.
## Pro Gebiet eine .tres in Resources/Encounters/ anlegen und der EncounterZone zuweisen.

# TODO: @export var entries: Array[Dictionary] = []
#       je Eintrag: {"monster": MonsterData, "min_level": 2, "max_level": 5, "weight": 30}
#       (oder eine eigene kleine Resource "EncounterEntry", damit der Inspector schöner ist)

func roll() -> Dictionary:
	# TODO:
	# Summe aller weights bilden, Zufallszahl ziehen, passenden Eintrag finden
	# return {"monster": eintrag.monster, "level": randi_range(eintrag.min_level, eintrag.max_level)}
	return {}
