# Tutorial: Spieler, Kamera, NPCs und Dialoge (2D von oben)

Stand: 2026-11-05, Godot 4.7. Alles hier ist schon im Projekt und funktioniert.
Zum Ausprobieren: `Szene/Prototype/spieler_npc_test.tscn` öffnen und **F6** drücken.
Steuerung: **WASD** laufen, **E** reden / Text weiter.

| Datei | Was sie macht |
|---|---|
| `Scripts/Overworld/player_controller.gd` | Spieler läuft Feld für Feld (16 px), redet mit NPCs |
| `Scripts/Overworld/overworld_camera.gd` | Kamera folgt dem Spieler, bleibt in der Map |
| `Scripts/Overworld/npc.gd` | NPC zum Ansprechen oder Trainer mit Sichtlinie |
| `Scripts/UI/dialogue_box.gd` | Textbox (Autoload `DialogueBox`) |
| `Szene/Player/Player.tscn` | fertige Spieler-Szene |
| `Szene/NPCs/Human/Template_Human.tscn` | Vorlage für alle Menschen-NPCs |

---

## 1. Wie die Bewegung funktioniert

Die Welt ist ein Raster aus 16×16-Feldern (wie das Grassland-Tileset). Der Spieler steht immer genau in der Mitte eines Feldes.

1. Taste gedrückt → Richtung merken (`facing`).
2. `test_move()` prüft, ob auf dem nächsten Feld eine Wand oder ein NPC ist. Wenn ja: nur umdrehen.
3. Sonst schiebt ein **Tween** den Spieler in `walk_time` Sekunden (Standard 0,2) genau ein Feld weiter.
4. Danach: Signal `stepped` (z. B. für hohes Gras) und alle Trainer prüfen, ob sie dich sehen.

Wände funktionieren automatisch, wenn die TileMapLayer der Map eine **Physics Layer** hat und die Wand-Tiles eine Kollisionsform haben (siehe Map-Tutorial).

Pixel-Art scharf machen (einmal): **Projekt > Projekteinstellungen > Rendering > Textures > Default Texture Filter = Nearest**.

## 2. Die Spieler-Szene

```
Player (CharacterBody2D, player_controller.gd)
├── AnimatedSprite2D
├── CollisionShape2D      Rechteck 14×14 (etwas kleiner als ein Feld!)
├── InteractRay (RayCast2D)   zeigt immer in Blickrichtung
└── Camera2D (overworld_camera.gd, Zoom 3)
```

Spieler in eine Map setzen: `Player.tscn` aus dem FileSystem in die Map ziehen. Die Position rastet beim Start automatisch auf die nächste Feldmitte ein.

### Laufanimation einbauen

Im Moment ist nur das Godot-Icon als Platzhalter drin. Für echte Sprites:

1. `AnimatedSprite2D` anklicken → unten das **SpriteFrames**-Panel.
2. Diese 8 Animationen anlegen (Namen genau so):
   `idle_down`, `idle_up`, `idle_left`, `idle_right`, `walk_down`, `walk_up`, `walk_left`, `walk_right`
3. Bei jeder Animation die Bilder aus deinem Spritesheet hinzufügen („Add frames from sprite sheet“).

Das Skript spielt automatisch `walk_<richtung>` beim Laufen und `idle_<richtung>` im Stand. Fehlt eine Animation, passiert einfach nichts.

Tipp für links/rechts mit nur einem Bild: Statt `walk_left` kannst du später `sprite.flip_h = facing == Vector2.LEFT` in `play_anim()` ergänzen.

## 3. Die Kamera

Die `Camera2D` hängt direkt am Spieler, damit sie ihm Feld für Feld folgt. Damit sie nicht über den Rand der Map schaut:

1. In der Map die **Boden-TileMapLayer** anklicken.
2. Rechts **Node > Groups** → Gruppe `ground` hinzufügen.

Das Skript liest beim Start die Größe der bemalten Fläche und setzt die `limit_*`-Werte der Kamera. Den Zoom (wie groß alles aussieht) stellst du im Inspector der Camera2D ein.

## 4. Einen NPC machen

1. `Szene/NPCs/Human/Template_Human.tscn` in die Map ziehen.
2. Im Inspector ausfüllen:
   - **Npc Name**: steht oben in der Textbox
   - **Dialogue Lines**: jede Zeile ist eine Seite in der Textbox
   - **Facing**: Blickrichtung, z. B. `(0, 1)` = unten, `(-1, 0)` = links
3. Fertig. Der NPC blockiert den Weg, und wenn der Spieler davor steht und **E** drückt, dreht er sich um und redet.

Eigenes Aussehen: Rechtsklick auf den NPC in der Map → **Editable Children** → im AnimatedSprite2D andere SpriteFrames einsetzen. Oder `Template_Human.tscn` duplizieren und z. B. `Oma.tscn` nennen.

## 5. Einen Trainer machen

Wie ein NPC, zusätzlich in der Gruppe **Trainer** im Inspector:

- **Is Trainer** anhaken
- **Sight Range**: wie viele Felder weit er schaut (Standard 4)
- **Facing**: dahin schaut er, dort sieht er den Spieler
- **Defeated Lines**: was er nach dem Kampf sagt

Ablauf: Läuft der Spieler in die Sichtlinie (`SightRay`), friert der Spieler ein, der Trainer läuft bis vor ihn, sagt seine `Dialogue Lines`, dann startet der Kampf. Wände blockieren die Sicht.

Der Kampf selbst ist noch nicht angeschlossen. In `npc.gd` in `_challenge()` steht die Stelle mit `TODO`, dort kommt später `SceneSwitcher.start_battle(...)` hin. Auch `defeated` wird noch nicht gespeichert; das kommt mit `GameState`.

## 6. Die Textbox selbst benutzen

`DialogueBox` ist als Autoload eingetragen und überall erreichbar. Für Schilder, Story-Szenen usw.:

```gdscript
func interact(player: Node2D) -> void:
	await DialogueBox.show_lines(["Route 1", "Nach Schuttgart →"])
	# hier geht es erst weiter, wenn der Text weggeklickt ist
```

Jeder Node mit einer Funktion `interact(player)` und einer Kollisionsform kann angesprochen werden. So baust du z. B. ein Schild: `StaticBody2D` + `CollisionShape2D` + kleines Skript mit der Funktion oben.

Aussehen der Box: kommt aus `Assets/UI/main_theme.tres`. Schreibgeschwindigkeit: `CHARS_PER_SEC` oben in `dialogue_box.gd`.

## 7. Häufige Fehler

| Problem | Lösung |
|---|---|
| Spieler läuft durch Wände | TileSet braucht Physics Layer + Kollision auf den Wand-Tiles |
| Spieler bleibt an allem hängen | CollisionShape kleiner als 16×16 machen (14×14) |
| E macht nichts | Spieler muss direkt davor stehen **und** hinschauen; Ziel braucht Kollision und `interact()` |
| Trainer reagiert nicht | `Is Trainer` an? `Facing` zeigt zum Weg? Wand dazwischen? |
| Pixel sind verschwommen | Default Texture Filter = Nearest (siehe oben) |
