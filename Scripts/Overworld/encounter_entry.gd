extends Resource
class_name EncounterEntry

## Ein Eintrag einer EncounterTable: welches Monster, welches Level, wie häufig.

@export var monster: MonsterData
@export var min_level: int = 2
@export var max_level: int = 5
@export var weight: int = 10    # höher = häufiger
