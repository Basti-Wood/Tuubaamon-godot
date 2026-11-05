extends Node

## Tutorial-Test für Monster und Attacken.
## Szene/DEBUg/monster_test.tscn öffnen und mit F6 starten. Ausgabe unten im "Output".

func _ready() -> void:
	var glimmi := MonsterInstance.create(load("res://Resources/Monsters/Glimmi.tres"), 5)
	_print(glimmi)
	glimmi.gain_exp(500)   # 100 + 500 EP → Level 9, lernt auf Level 8 Funkenregen
	_print(glimmi)
	for move in glimmi.moves:
		print("  %s: Timing %s, Mehrfachtreffer: %s" % [move.MoveName, move.get_timing_hits(), move.IsMultiHit])

func _print(mon: MonsterInstance) -> void:
	print("%s Lv.%d  KP %d/%d  ANG %d  GLÜCK %d  Attacken: %s" % [
		mon.get_display_name(), mon.level, mon.current_hp, mon.get_max_hp(),
		mon.get_stat("attack"), mon.get_stat("luck"),
		mon.moves.map(func(m): return m.MoveName)])
