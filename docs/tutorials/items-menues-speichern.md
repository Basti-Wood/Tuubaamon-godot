# Tutorial: Items, Menüs und Speichern

Dieses Tutorial zeigt, wie Items, Inventar, Team- und Pausemenü, Story-Flags und Spielstände zusammenhängen.
Der Code dazu ist schon im Projekt und funktioniert. Du musst ihn nur benutzen und erweitern.

## 1. Autoloads (globale Skripte)

Ein Autoload ist ein Skript, das beim Spielstart automatisch geladen wird und von überall erreichbar ist.
Eingetragen sind schon:

| Name | Skript | Wofür |
|---|---|---|
| `GameState` | `Scripts/Core/game_state.gd` | Geld, Inventar, Team, Story-Flags, aktuelle Map |
| `SaveManager` | `Scripts/Core/save_manager.gd` | Spielstand speichern und laden |

Einen neuen Autoload trägst du so ein: **Projekt → Projekteinstellungen → Globals → Autoload**, Skript wählen, Namen eingeben, **Hinzufügen**.
Danach kannst du in jedem Skript z. B. `GameState.money` schreiben.

## 2. Ein neues Item anlegen

1. In `Resources/Items/` die Vorlage `1ItemTemplate.tres` duplizieren (Rechtsklick → **Duplicate**), z. B. `Hypertrank.tres`.
2. Im Inspector ausfüllen, z. B. `ItemName = Hypertrank`, `RestoresHP = 200`.

Was die Felder bedeuten, steht in `docs/ANLEITUNG.md`, Abschnitt 4.
Benutzt wird ein Item mit `item.use_on(monster)` (in `Scripts/Item/ItemTemplate.gd`). Es heilt KP oder belebt wieder und gibt `false` zurück, wenn es nichts bringt.

> `use_on` braucht `current_hp` und `get_max_hp()` in `MonsterInstance`. Das kommt aus dem Monster-Tutorial.

### Items ins Inventar geben

```gdscript
var trank: ItemData = load("res://Resources/Items/Potion.tres")
GameState.add_item(trank, 3)      # 3 Tränke dazu
GameState.remove_item(trank)      # 1 Trank weg, gibt false zurück, wenn keiner da ist
GameState.has_item(trank)         # true / false
GameState.item_count(trank)       # Anzahl
```

Das Inventar ist ein Dictionary `Item-Pfad → Anzahl`. So lässt es sich ganz einfach speichern.
Eine Truhe oder ein NPC, der etwas schenkt, ruft einfach `GameState.add_item(...)` auf.

## 3. VM-Items (Baum fällen, Fels zerschlagen)

VMs sind bei uns Items, keine Attacken. Beispiel: `Resources/Items/Axt.tres` (Category `KEY_ITEM`).

1. In der Map einen **StaticBody2D** anlegen, mit `Sprite2D` (der Baum) und `CollisionShape2D`.
2. Skript `Scripts/Overworld/hm_obstacle.gd` draufziehen.
3. Im Inspector: `Required Item` = `Axt.tres`, `Cleared Flag` = z. B. `baum_route1_weg`.

Wenn der Spieler davor steht und interagiert, ruft er `interact(self)` auf (siehe Spieler-Tutorial).
Hat er die Axt, verschwindet der Baum und das Flag wird gesetzt. Dadurch bleibt der Baum auch nach Laden weg.

## 4. Story-Flags

Flags merken sich, was schon passiert ist:

```gdscript
GameState.set_flag("arena_1_besiegt")
if GameState.has_flag("arena_1_besiegt"):
    print("Orden 1 hast du schon!")
```

Typische Flags: Arena besiegt, NPC schon angesprochen, Truhe geöffnet, Hindernis weg.
Gib jedem Flag einen eindeutigen Namen (am besten `ort_ding`, z. B. `route1_truhe_offen`).

## 5. Amulette aufwerten

Amulette (`Scripts/Item/amulet_data.gd`, Klasse `AmuletData`) haben eine Material-Stufe und Steine mit Boni.
`amulet.upgrade()` verbraucht Material. Herstellen und Aufwerten: siehe `schmuck-crafting.md`.

Wichtig: Jedes gefangene Monster braucht sein eigenes Exemplar, also beim Fangen `amulett.duplicate()` benutzen.
Sonst wertest du mit einem Amulett alle Monster auf, die dasselbe Amulett haben.

## 6. Pausemenü, Inventar und Team

Das Pausemenü baut seine Knöpfe selbst, du brauchst keine eigene Szene:

1. In deiner Map-Szene einen **CanvasLayer** hinzufügen und `PauseMenu` nennen.
2. Skript `Scripts/UI/pause_menu.gd` draufziehen.
3. Spiel starten, **Esc** drücken.

Knöpfe: **Weiter**, **Team**, **Inventar**, **Speichern**, **Hauptmenü**.

- **Inventar** (`Scripts/UI/inventory_menu.gd`): Item doppelklicken, dann das Monster doppelklicken, an dem es benutzt wird.
- **Team** (`Scripts/UI/party_menu.gd`): zwei Monster nacheinander doppelklicken, dann tauschen sie die Plätze.

Das Menü pausiert das Spiel mit `get_tree().paused = true`. Es läuft selbst weiter, weil es `process_mode = ALWAYS` hat.
Einen neuen Knopf fügst du in `_ready()` in `pause_menu.gd` hinzu:

```gdscript
_add_button("Karte", func(): print("Karte öffnen"))
```

## 7. Speichern und Laden

```gdscript
SaveManager.save_game(1)      # Slot 1 speichern
SaveManager.load_game(1)      # Slot 1 laden, gibt false zurück, wenn es keinen gibt
SaveManager.has_save(1)       # gibt es einen Spielstand?
```

Gespeichert wird eine JSON-Datei in `user://saves/slot_1.json`.
Unter Windows liegt sie in `%APPDATA%\Godot\app_userdata\Tuubaamon\saves\`. Du kannst sie mit einem Texteditor öffnen.

Gespeichert werden Geld, Inventar, Team, Box, Story-Flags, Map und Spawn-Punkt.
Monster werden über `to_dict()` und `MonsterInstance.from_dict()` gespeichert. Diese beiden Funktionen füllt das Monster-Tutorial aus.

**Neue Daten speichern**, z. B. die Spielzeit:

1. In `game_state.gd`: `var play_time: float = 0.0`
2. In `save_game()` ins Dictionary: `"play_time": GameState.play_time,`
3. In `load_game()`: `GameState.play_time = data.get("play_time", 0.0)`

Mit `data.get(..., Standardwert)` laden auch alte Spielstände ohne den neuen Eintrag.

Das Hauptmenü benutzt schon `GameState.new_game()` (Neues Spiel) und `SaveManager.load_game(1)` (Fortsetzen).
Die Start-Map und das Setzen des Spielers an den Spawn-Punkt kommen aus dem Map-Tutorial.

## 8. Schnell testen

In irgendeinem Skript in `_ready()`:

```gdscript
GameState.new_game()
GameState.add_item(load("res://Resources/Items/Potion.tres"), 5)
SaveManager.save_game(1)
print(GameState.inventory)
```
