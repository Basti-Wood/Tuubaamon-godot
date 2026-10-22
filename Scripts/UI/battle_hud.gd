extends CanvasLayer

## PLATZHALTER - Anzeige im Kampf: KP-Balken, Namen, Aktionsmenü, Timing-Anzeige.

signal action_chosen(action: String, payload)    # "attack" + MoveData, "item" + ItemData, ...

func show_battlers(player_monster, enemy_monster) -> void:
	# TODO: Namen, Level, KP-Balken für beide Seiten setzen
	pass

func update_hp(is_player: bool, current: int, max_hp: int) -> void:
	# TODO: KP-Balken mit Tween runterlaufen lassen
	pass

func open_action_menu(monster) -> void:
	# TODO: Buttons Attacke / Item / Wechseln / Fangen / Fliehen
	# Attacke -> Untermenü mit den Attacken des Monsters (Name, Typ, AP)
	pass

func show_timing_result(tier: int) -> void:
	# TODO: "Okay" / "Gut" / "Sehr gut!" / "Exzellent!!" groß einblenden (ActionCommand.TIER_NAMES)
	pass
