extends Control

## PLATZHALTER - Inventar: Items nach Kategorie (Enums.ItemCategory) anzeigen und benutzen.

func open(in_battle := false) -> void:
	# TODO: Tabs pro Kategorie, nur Items zeigen, deren UseContext passt (BATTLE / OVERWORLD / BOTH)
	pass

func _on_item_used(item: ItemData, target) -> void:
	# TODO: Effekt anwenden (RestoresHP usw.), Anzahl verringern, Menü schließen
	pass
