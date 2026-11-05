extends ItemData
class_name AmuletData

## Schmuck/Amulett, in dem Monster gefangen werden (wie bei Huntik).
## Leerer Schmuck = Rohling. Material = Stufe, jede Stufe bringt eine Fassung mehr.

enum Form { RING, AMULETT, ARMREIF, OHRRING }
enum Tier { KUPFER, SILBER, GOLD, RELIKT }

@export var form: Form = Form.AMULETT
@export var tier: Tier = Tier.KUPFER
@export var color: Color = Color.WHITE
@export var engraving: String = ""
@export var gems: Array[GemData] = []
## Kosten pro Aufwertung: Index 0 = Kupfer→Silber, 1 = Silber→Gold, 2 = Gold→Relikt.
@export var upgrade_recipes: Array[CraftingRecipe] = []
## Gefangenes Monster. null = Rohling.
@export var monster: MonsterData = null

func sockets() -> int:
	return tier + 1

func catch_bonus() -> float:
	return 1.0 + tier * 0.25

func can_upgrade(bag: Dictionary) -> bool:
	return tier < Tier.RELIKT and tier < upgrade_recipes.size() and upgrade_recipes[tier].can_craft(bag)

func upgrade(bag: Dictionary) -> bool:
	if not can_upgrade(bag):
		return false
	upgrade_recipes[tier].consume(bag)
	tier += 1
	return true

func add_gem(gem: GemData) -> bool:
	if gems.size() >= sockets():
		return false
	gems.append(gem)
	return true

## Summe eines Bonus über alle Steine, z. B. stat_bonus("bonus_attack").
func stat_bonus(stat: String) -> int:
	var total := 0
	for gem in gems:
		total += gem.get(stat)
	return total
