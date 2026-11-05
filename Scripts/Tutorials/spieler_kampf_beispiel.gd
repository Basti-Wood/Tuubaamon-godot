extends Node

## Beispiel aus docs/tutorials/spieler-faehigkeiten.md
## Szene starten (F6) und die Ausgabe unten im Editor lesen.

func _ready() -> void:
	var player := PlayerData.new()
	player.player_name = "Tuubaa"

	var fuego := MonsterData.new()
	fuego.name = "Fuego"
	fuego.primary_type = Enums.Type.FIRE
	fuego.base_hp = 60
	fuego.base_attack = 70

	# 1. Kein Monster draußen -> der Spieler kämpft selbst
	var mensch := MergeSystem.create_player_battler(player, player.level)
	print("%s kämpft selbst: HP %d, ATK %d, Typen %s" % [mensch.name, mensch.max_hp, mensch.attack, mensch.types])

	# 2. Fusion geht nur, wenn die Story sie freigeschaltet hat
	print("Fusion möglich? ", player.has_ability("fusion"))
	player.unlock_ability("fusion")

	if player.has_ability("fusion"):
		var merge := MergeSystem.new()
		merge.max_merge_turns = -1  # -1 = hält bis zum Kampfende
		var fusion := merge.merge(player, fuego, player.level)
		print("%s: HP %d, ATK %d, Typen %s" % [fusion.name, fusion.max_hp, fusion.attack, fusion.types])
		merge.free()

	# 3. Overworld-Fähigkeit: Fels zerschlagen
	var fels := AbilityObstacle.new()
	add_child(fels)
	print("Fels weg? ", fels.interact(player))
	player.unlock_ability("zerschmettern")
	print("Fels weg? ", fels.interact(player))
