# Tutorial: Eine Map mit Terrain bauen (2D top-down)

Fertiges Beispiel zum Anschauen: `Szene/World/Beispiel/beispiel_route.tscn` öffnen und **F6** drücken. Mit WASD laufen, oben am Weg geht es in den Wald und unten wieder zurück.

Was du am Ende hast:
- eine Map aus mehreren **TileMapLayer**n (Boden, Gras, Hohes Gras, Objekte)
- Gras, das sich beim Malen automatisch an die Ränder anpasst (**Terrain**)
- Bäume, durch die man nicht laufen kann (**Kollision**) und hinter denen man verschwindet (**Y-Sort**)
- einen **Ausgang** in eine andere Map

---

## 1. Das TileSet

Das TileSet ist schon fertig: `Assets/TileSets/grassland.tres`. Es wird von allen Maps benutzt. Doppelklick darauf öffnet unten den **TileSet**-Reiter.

Es enthält:

| Quelle | Bild | Inhalt |
|---|---|---|
| 0 | `FD_Ground_Tiles.png` | Terrain-Kacheln für **Gras** und **Hohes Gras** |
| 1 | `FD_Grasslands.png` | Erde (volle Kachel) und ein Baum mit Kollision |

Kachelgröße: **16 × 16** Pixel.

### So kommt eine neue Kachel dazu (z. B. ein Stein)

1. TileSet öffnen, links Quelle **1** wählen, oben auf **Setup** stellen.
2. Im Bild die Kachel anklicken, damit sie erstellt wird. Für größere Objekte (Baum = 1 × 2) die Kachel am Rand größer ziehen.
3. Auf **Select** stellen, Kachel anklicken, rechts im Inspector:
   - **Rendering → Texture Origin**: bei 1 × 2 großen Objekten `y = 8`, dann steht das Objekt mit dem Fuß auf seiner Zelle.
   - **Physics → Physics Layer 0**: mit **F** ein Viereck setzen und auf den unteren Teil (Stamm/Fuß) verkleinern. Nur dort soll man nicht durchkommen, sonst klebt man an der Baumkrone fest.

### So kommt ein neues Terrain dazu (z. B. dunkles Gras)

Das Terrain-Set 0 steht auf **Match Corners**: jede Kachel sagt für ihre vier Ecken, ob dort das Terrain ist. Daraus sucht Godot beim Malen selbst die passende Randkachel.

1. TileSet-Ressource im Inspector öffnen → **Terrain Sets → Terrain Set 0 → Terrains → Add Element**, Namen und Farbe vergeben.
2. Im TileSet-Reiter Quelle **0**, oben **Paint**, dann **Terrains** wählen, Terrain-Set 0 und dein neues Terrain.
3. Die Kacheln des Blocks anmalen: Klick auf eine **Ecke** einer Kachel setzt diese Ecke. Ecken, auf denen das Gras liegt, werden angemalt, leere Ecken nicht.

Jeder Block in `FD_Ground_Tiles.png` ist 3 Kacheln breit und 8 hoch (die oberste Zeile ist leer) und immer gleich aufgebaut. So sind die Ecken bei **Gras** gesetzt (X = Ecke gehört zum Terrain, Reihenfolge oben-links, oben-rechts / unten-links, unten-rechts):

```
Zeile 1:  XX/X.   XX/..   XX/.X      (Innenecken und obere Kante)
Zeile 2:  X./X.   (leer)  .X/.X
Zeile 3:  X./XX   ../XX   .X/XX
Zeile 4:  ../.X   ../XX   ../X.      (Außenecken und Kanten)
Zeile 5:  .X/.X   XX/XX   X./X.      (Mitte = volle Kachel)
Zeile 6:  .X/..   XX/..   X./..
Zeile 7:  .X/X.   (leer)  X./.X      (diagonale Stücke)
```

Die anderen grünen Blöcke und das hohe Gras (links unten) sind genauso aufgebaut, du kannst sie also gleich anmalen.

> Die braunen und gelben Blöcke (Erde, Sand) passen **nicht** in dieses Schema. Deshalb ist Erde im Beispiel eine volle Kachel unter dem Gras: wo kein Gras gemalt ist, sieht man den Weg.

---

## 2. Neue Map anlegen

1. *Scene → New Scene* → **2D Scene**. Root umbenennen, z. B. `Route01`.
2. Im Inspector des Roots: **CanvasItem → Texture → Filter = Nearest**. Sonst wird die Pixelgrafik verschwommen.
   (Oder einmal für das ganze Projekt: *Projekteinstellungen → Rendering → Textures → Default Texture Filter = Nearest*.)
3. Speichern unter `Szene/World/<Region>/<Name>.tscn`.

Aufbau, so wie im Beispiel:

```
Route01 (Node2D)                 Texture Filter = Nearest
├── Boden (TileMapLayer)         Gruppe "boden", volle Erde-Kacheln
├── Gras (TileMapLayer)          Terrain "Gras"
├── HohesGras (TileMapLayer)     Terrain "Hohes Gras"
├── Welt (Node2D)                Y Sort Enabled = an
│   ├── Objekte (TileMapLayer)   Y Sort Enabled = an, Bäume/Steine
│   └── Spieler                  (Instanz)
├── Spawns (Node2D)
│   ├── start (Marker2D)
│   └── von_route_02 (Marker2D)
└── Ausgang_Nord (Area2D)        map_transition.gd
    └── CollisionShape2D
```

Für jeden TileMapLayer im Inspector **Tile Set** = `Assets/TileSets/grassland.tres` setzen.

---

## 3. Malen

**Boden:** Layer `Boden` auswählen, unten im **TileMap**-Reiter auf **Tiles**, Quelle 1, die Erde-Kachel wählen. Mit dem **Rechteck-Werkzeug** (R) die ganze Map füllen.

Den Layer `Boden` in die Gruppe **boden** stecken (Node-Reiter → Groups). Die Kamera liest daraus die Größe der Map und fährt nicht über den Rand.

**Gras:** Layer `Gras` auswählen, unten auf **Terrains**, Terrain-Set 0, **Gras**. Jetzt einfach malen:
- **Pinsel** für Freihand, **Rechteck** für große Flächen
- **Rechtsklick** radiert. Wo du radierst, entsteht ein Weg, und die Grasränder passen sich automatisch an.

**Hohes Gras:** genauso auf dem Layer `HohesGras`. Dort kommt später die Encounter-Zone hin (eigenes Tutorial).

Tipp: Wege mindestens **3 Kacheln breit** radieren, sonst werden sie sehr schmal.

---

## 4. Kollision und Y-Sort

- Kollision kommt aus dem TileSet (Physics Layer 0). Ein Baum auf dem Layer `Objekte` blockiert also automatisch. Der Spieler braucht dafür nur einen `CharacterBody2D` mit Kollisionsmaske 1 (Standard).
- **Y-Sort** heißt: wer weiter unten steht, wird davor gezeichnet. Läuft der Spieler hinter einem Baum, verschwindet er hinter der Krone.
  Dafür müssen `Welt` **und** `Objekte` **Y Sort Enabled** haben und der Spieler muss in `Welt` hängen.
- Der Spieler muss seinen Ursprung (Position 0,0) an den **Füßen** haben, nicht in der Mitte. Im Beispielspieler ist dafür das Sprite mit `offset` nach oben geschoben.
- Boden, Gras und Hohes Gras gehören **nicht** in `Welt`, sonst werden sie auch sortiert und liegen plötzlich über dem Spieler.

---

## 5. Ausgänge und Spawn-Punkte

**Spawn-Punkte:** Unter `Spawns` pro Eingang einen `Marker2D` mit sprechendem Namen, z. B. `von_route_02`. Den Marker **2 Kacheln vor** den Ausgang setzen, nicht darauf, sonst wird man sofort zurückgeschickt.

**Ausgang:**
1. `Area2D` hinzufügen, Skript `Scripts/Overworld/map_transition.gd` drauf.
2. Als Kind ein `CollisionShape2D` mit `RectangleShape2D`, so breit wie der Weg, an den Rand der Map setzen.
3. Im Inspector:
   - **Target Map**: die Ziel-Szene, z. B. `Szene/World/BW/Route02.tscn`
   - **Target Spawn**: Name des Markers in der Ziel-Map, z. B. `von_route_01`

Das Skript:

```gdscript
extends Area2D

@export_file("*.tscn") var target_map: String
@export var target_spawn: String = "start"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneSwitcher.go_to_map(target_map, target_spawn)
```

`SceneSwitcher` (Autoload, `Scripts/Core/scene_switcher.gd`) lädt die neue Map und setzt den Spieler auf den Marker:

```gdscript
func go_to_map(map_path: String, spawn_name: String) -> void:
	get_tree().change_scene_to_file.call_deferred(map_path)
	await get_tree().scene_changed
	var marker := get_tree().current_scene.find_child(spawn_name) as Node2D
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if marker and player:
		player.global_position = marker.global_position
```

Damit das klappt, muss der Spieler in der Gruppe **player** sein.

---

## 6. Spieler und Kamera

Bis der richtige Spieler fertig ist (Tutorial „Spieler und NPCs"), kannst du `Szene/World/Beispiel/beispiel_spieler.tscn` in `Welt` instanziieren. Er hat schon:

- Gruppe `player`
- `Camera2D` mit `zoom = 3` und `Scripts/Overworld/overworld_camera.gd`, die sich an die Größe des Layers in der Gruppe `boden` anpasst.

Die Kamera hängt am Spieler, dadurch folgt sie ihm von selbst. **Position Smoothing** an macht die Bewegung weicher.

---

## Checkliste für jede neue Map

- [ ] Root `Node2D`, Texture Filter **Nearest**
- [ ] `Boden` in Gruppe **boden**
- [ ] Objekte und Spieler in einem `Node2D` mit **Y Sort**
- [ ] pro Eingang ein `Marker2D`, 2 Kacheln vor dem Ausgang
- [ ] pro Ausgang eine `Area2D` mit `map_transition.gd`, **Target Map** und **Target Spawn** gesetzt
- [ ] in der Ziel-Map gibt es den Marker mit genau diesem Namen
