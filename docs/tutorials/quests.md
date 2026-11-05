# Quests (Archäologie und Künstler)

Brainstorm: Tuubaa macht „Missionen“ für ihre Professor-Mutter (Archäologie-Prüfung), Arenaleiter sind Künstler und geben Hinweise. Zwei Quest-Stränge plus Nebenquests (z. B. Thüringen-Inseln, künstliche Monster).

## 1. Quest als Resource

`Scripts/Quests/quest_data.gd`:

```gdscript
extends Resource
class_name QuestData

@export var id := ""                 # z. B. "archaeo_1"
@export var title := ""
@export_multiline var description := ""
@export var strand := "archaeologie" # "archaeologie", "kuenstler", "neben"
## Jeder Schritt ist erledigt, wenn sein Story-Flag gesetzt ist.
@export var step_flags: Array[String] = []
@export var step_texts: Array[String] = []
@export var reward_item: Resource    # ItemData, optional
```

Neue Quest: Rechtsklick in `Resources/Quests/` > *Neu > Resource > QuestData*.

## 2. Fortschritt über Flags

Quests haben keinen eigenen Speicher. Ein Schritt ist erledigt, wenn sein Flag gesetzt ist (siehe Story-Tutorial). Das speichert sich automatisch mit den Story-Flags.

`Scripts/Quests/quest_log.gd` (Autoload **QuestLog**):

```gdscript
extends Node

const QUEST_FOLDER := "res://Resources/Quests/"

func get_all() -> Array[QuestData]:
	var list: Array[QuestData] = []
	for file in DirAccess.get_files_at(QUEST_FOLDER):
		if file.ends_with(".tres"):
			list.append(load(QUEST_FOLDER + file))
	return list

func is_started(q: QuestData) -> bool:
	return GameState.has_flag("quest_" + q.id)

func current_step(q: QuestData) -> int:
	for i in q.step_flags.size():
		if not GameState.has_flag(q.step_flags[i]):
			return i
	return q.step_flags.size()  # alle erledigt

func is_done(q: QuestData) -> bool:
	return current_step(q) >= q.step_flags.size()

func start(q: QuestData) -> void:
	GameState.set_flag("quest_" + q.id)
```

## 3. Quest annehmen beim NPC

Im NPC nach dem Dialog:

```gd
@export var quest: QuestData
...
if quest and not QuestLog.is_started(quest):
	QuestLog.start(quest)
```

Einen Schritt erledigst du überall mit `GameState.set_flag("archaeo_1_platte_gefunden")`, z. B. im Cutscene-Trigger oder nach einem Rätsel.

## 4. Quest-Liste im Menü

In einem `VBoxContainer` für jede gestartete Quest ein `Label` mit `q.title` und `q.step_texts[QuestLog.current_step(q)]`. Fertige Quests grau (`modulate = Color(1,1,1,0.5)`).
