# Lager (Box) und Dojo

Brainstorm: Panda oder Sora entwirft das Lagersystem. Es gibt **ein** Dojo (wie eine Arena), dort lernt man eine Attacke und kann Monster trainieren (wie EVs). Später kennen Ömers Leute dein Team über das Lager und kontern es.

## 1. Lager

`GameState` hat schon `party` (max. 6) und `box`. Verschieben:

```gdscript
extends Node
class_name Storage

const MAX_PARTY := 6

static func deposit(party: Array, box: Array, index: int) -> bool:
	if party.size() <= 1:
		return false   # mindestens 1 im Team (außer Monless-Run)
	box.append(party.pop_at(index))
	return true

static func withdraw(party: Array, box: Array, index: int) -> bool:
	if party.size() >= MAX_PARTY:
		return false
	party.append(box.pop_at(index))
	return true
```

Aufruf: `Storage.deposit(GameState.party, GameState.box, 2)`. Die Oberfläche sind zwei `ItemList`s (Team / Lager) mit einem Button dazwischen.

## 2. Dojo-Training

Jedes Monster hat Trainingspunkte pro Wert (wie EVs). Im Dojo bezahlt man (Geld oder Kämpfe), um sie zu erhöhen.

In `MonsterInstance`:

```gd
@export var training := {"hp": 0, "atk": 0, "def": 0, "satk": 0, "sdef": 0, "init": 0}
const TRAINING_MAX_STAT := 63
const TRAINING_MAX_TOTAL := 127
```

```gdscript
extends RefCounted
class_name Dojo

static func train(training: Dictionary, stat: String, amount: int) -> int:
	var total := 0
	for v in training.values():
		total += v
	var add := mini(amount, mini(63 - training[stat], 127 - total))
	training[stat] += max(add, 0)
	return max(add, 0)   # wie viel wirklich dazukam
```

In `get_stat()`: `+ training[stat_name] / 4` auf den Wert rechnen.

## 3. Ömer kontert dein Lager (Late Game)

Ein Counter-Team aus dem Lager bauen: Typ zählen, der im Team + Lager am häufigsten ist, und Monster nehmen, die dagegen stark sind.

```gd
var counts := {}
for m in GameState.party + GameState.box:
	for t in m.species.types:
		counts[t] = counts.get(t, 0) + 1
var top_type = counts.keys().reduce(func(a, b): return a if counts[a] > counts[b] else b)
# Jetzt aus einer Liste möglicher Ömer-Monster die nehmen, bei denen
# TypeChart.get_effectiveness(ihr_typ, [top_type]) > 1 ist.
```
