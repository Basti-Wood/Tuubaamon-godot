extends Resource
class_name EncounterTable

## Welche wilden Monster in einem Gebiet auftauchen.
## Pro Gebiet eine .tres in Resources/Encounters/ anlegen und der EncounterZone zuweisen.

@export var entries: Array[EncounterEntry] = []

## Zieht ein zufälliges Monster nach Gewicht und erzeugt ein Exemplar davon.
func roll() -> MonsterInstance:
	var total := 0
	for entry in entries:
		total += entry.weight
	if total <= 0:
		return null

	var pick := randi_range(1, total)
	for entry in entries:
		pick -= entry.weight
		if pick <= 0:
			return MonsterInstance.create(entry.monster, randi_range(entry.min_level, entry.max_level))
	return null
