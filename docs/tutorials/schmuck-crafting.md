# Tutorial: Schmuck herstellen und aufwerten

Monster werden in Schmuck gefangen (wie bei Huntik). Leerer Schmuck heißt **Rohling**.
Hier lernst du Materialien, Rezepte, die Werkstatt und das Aufwerten.

## Was es gibt

| Datei | Wofür |
|---|---|
| `Scripts/Crafting/crafting_recipe.gd` | `CraftingRecipe`: Zutaten → Ergebnis |
| `Scripts/Item/amulet_data.gd` | `AmuletData`: Form, Material-Stufe, Farbe, Gravur, Steine, Aufwerten |
| `Scripts/Item/gem_data.gd` | `GemData`: Stein/Rune mit Stat-Bonus für die Fassungen |
| `Scripts/UI/crafting_menu.gd` | `CraftingMenu`: einfaches Werkstatt-Menü |
| `Scripts/Crafting/crafting_station.gd` | `CraftingStation`: Werkstatt in der Map |
| `Szene/Prototype/crafting_demo.tscn` | Demo zum Ausprobieren (F6) |

Material kommt aus dem Inventar in `GameState` (siehe `items-menues-speichern.md`).
Fertige Beispiele: `Resources/Materials/`, `Resources/Recipes/`, `Resources/Items/Kupfer_Amulett.tres` und `Rubin.tres`.

## 1. Demo ausprobieren

Öffne `Szene/Prototype/crafting_demo.tscn` und drücke **F6**.
In der Ausgabe steht:

```
Hergestellt: Kupfer-Amulett | Kupfer übrig: 2
Aufwerten: true | Stufe: SILBER | Fassungen: 2
Angriff-Bonus: 5 | Fangbonus: 1.25
```

Danach siehst du das Werkstatt-Menü. Wähle ein Rezept und klicke **Herstellen**.

## 2. Material anlegen

Materialien sind normale Items.

1. Rechtsklick auf `Resources/` → **Create New → Folder** → `Materials`.
2. Rechtsklick auf `Materials` → **Create New → Resource…** → `ItemData` → `Kupfererz.tres`.
3. Im Inspector `ItemName`, `Icon`, `Description` ausfüllen. `Consumable` aus.

## 3. Stein (Rune) anlegen

**Create New → Resource…** → `GemData` → `Rubin.tres`. Im Inspector z. B. `bonus_attack = 5`.

## 4. Rohling anlegen

**Create New → Resource…** → `AmuletData` → `Resources/Items/Kupfer_Amulett.tres`.

- `ItemName`: Kupfer-Amulett
- `Category`: CAPTURE
- `form`, `tier` (KUPFER), `color` nach Wunsch
- `upgrade_recipes`: siehe Schritt 6

## 5. Rezept anlegen

**Create New → Resource…** → `CraftingRecipe` → `Resources/Recipes/Kupfer_Amulett.tres`.

- `recipe_name`: Kupfer-Amulett
- `ingredients`: **Add Key/Value Pair** → links `Kupfererz.tres` reinziehen, rechts `3`
- `result`: `Kupfer_Amulett.tres` reinziehen

Herstellen im Code:

```gdscript
recipe.craft()   # false, wenn Material fehlt
```

`craft()` zieht die Zutaten aus `GameState` ab und legt das Ergebnis ins Inventar.
Rohlinge liegen dort gestapelt. Beim Fangen bekommt jedes Monster ein eigenes Exemplar (`amulet.duplicate()`),
damit es eigene Gravur, Steine und Stufe hat.

## 6. Aufwerten

Material = Stufe: Kupfer → Silber → Gold → Relikt. Jede Stufe gibt eine Fassung mehr und einen besseren Fangbonus.

Die Kosten sind wieder `CraftingRecipe`s (nur `ingredients`, kein `result`).
Trag sie im Rohling unter `upgrade_recipes` ein:
Index 0 = Kupfer→Silber, 1 = Silber→Gold, 2 = Gold→Relikt.

```gdscript
if amulet.upgrade():             # zieht Material aus GameState ab, tier + 1
	print(amulet.sockets())      # Anzahl Fassungen
amulet.add_gem(rubin)            # false, wenn alle Fassungen voll
amulet.stat_bonus("bonus_attack")
amulet.catch_bonus()             # für die Fangformel
```

## 7. Eigener Schmuck

Form, Farbe und Gravur stehen direkt im `AmuletData`.
Für jede Form oder Farbe in der Werkstatt legst du einen eigenen Rohling + Rezept an.
Die Gravur setzt du am eigenen Exemplar, z. B. nach dem Fangen:

```gdscript
amulet.form = AmuletData.Form.RING
amulet.color = Color.GOLD
amulet.engraving = "Für Tuubaa"
```

Neue Formen trägst du im `enum Form` in `amulet_data.gd` ein.

## 8. Werkstatt in die Map setzen

1. In der Map: **Add Child Node** → `Area2D`, Script `crafting_station.gd` anhängen.
2. Als Kind eine `CollisionShape2D` mit Form (z. B. Rechteck vor dem Werktisch).
3. Ein `CanvasLayer` mit einem `PanelContainer` als Kind anlegen, Script `crafting_menu.gd` drauf.
4. Bei der Station im Inspector: `recipes` füllen, `menu` auf das Menü zeigen.

Der Spieler (`CharacterBody2D`) läuft in die Fläche und drückt **interact**.

## 9. Monster-Werte mit Schmuck

Beim Berechnen der Kampfwerte die Boni addieren, z. B.:

```gdscript
var attack = monster.base_attack + amulet.stat_bonus("bonus_attack")
```
