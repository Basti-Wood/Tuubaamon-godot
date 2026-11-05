# Bosse, Ömer und Trefferzonen

Brainstorm: Ömer (Wolfshybrid) mit Bunny-Tuubaamon, will sich mit dem Legendären vereinen. Seine **Schulter ist eine Schwachstelle**, fusioniert hat er mehrere Trefferzonen. Mods unter ihm, Mischmenschen mit Typ (je höher im Rang, desto mehr Veränderung), Boss-Monster in Ruinen, mehr als 6 Monster für starke Gegner.

## 1. Trefferzonen

Ein Boss bekommt eine Liste von Zonen. Der Spieler wählt vor der Attacke eine Zone.

```gdscript
extends Resource
class_name HitZone

@export var name := "Schulter"
@export var damage_multiplier := 1.5   # Schwachstelle > 1, Panzer < 1
@export var hp := 0                     # 0 = Zone kann nicht zerstört werden
@export var disables_move: Resource     # MoveData, die wegfällt, wenn die Zone kaputt ist
```

```gdscript
extends Node
class_name BossTarget

## Hängt am Boss im Kampf. Hält die Zonen und rechnet den Schaden um.

signal zone_broken(zone: HitZone)

@export var zones: Array[HitZone] = []
var zone_hp := {}

func _ready() -> void:
	for z in zones:
		zone_hp[z] = z.hp

func apply_hit(zone: HitZone, base_damage: int) -> int:
	var dmg := int(base_damage * zone.damage_multiplier)
	if zone.hp > 0 and zone_hp[zone] > 0:
		zone_hp[zone] = max(0, zone_hp[zone] - dmg)
		if zone_hp[zone] == 0:
			zone_broken.emit(zone)
	return dmg

func available_zones() -> Array[HitZone]:
	var out: Array[HitZone] = []
	out.assign(zones.filter(func(z): return z.hp == 0 or zone_hp[z] > 0))
	return out
```

Beispiel Ömer: Zone „Körper“ (×1.0) und „Schulter“ (×1.5). Fusioniert mit dem Legendären: zusätzlich „Ohren“, „Klauen“ mit eigener HP; zerbrechen sie, fällt eine Attacke weg.

## 2. Gegner-Trainer (Mods, Ömer)

Trainer-Daten als Resource, damit Mods schnell gebaut sind:

```gdscript
extends Resource
class_name TrainerData

@export var trainer_name := ""
@export var rank := 0                  # 0 = Handlanger ... 3 = Ömer
@export var team: Array[Resource] = [] # MonsterInstance, Ömer darf > 6
@export var wesen := 0                 # EnemyBrain.Wesen
@export var defeated_flag := ""
@export var hit_zones: Array[HitZone] = []  # wenn der Trainer selbst kämpft (Mischmensch)
```

Mischmenschen: Ein Mod mit `rank >= 1` kann selbst kämpfen wie der Spieler (siehe Fusions-Tutorial). Je höher `rank`, desto mehr `hit_zones` und Typen.

## 3. Boss-Monster in Ruinen

Ein Boss-Monster ist ein normales `MonsterInstance` mit höherem Level, plus `BossTarget`-Knoten im Kampf. Nach dem Sieg `GameState.set_flag(defeated_flag)`, damit es nicht wieder erscheint.
