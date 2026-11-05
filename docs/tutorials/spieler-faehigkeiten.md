# Tutorial: Spieler-Fähigkeiten und Fusion

Was du hier lernst:
1. Fähigkeiten des Spielers freischalten (Fusion, Zerschmettern, Klettern …)
2. Den Spieler selbst kämpfen lassen
3. Mit einem Monster fusionieren
4. Ein Hindernis in der Overworld bauen, das eine Fähigkeit braucht
5. Was `AbilityTemplate.gd` ist (Monster-Fähigkeiten, nicht Spieler)

Fertiges Beispiel: `Szene/Tutorials/spieler_kampf_beispiel.tscn` öffnen und **F6** drücken. Die Ausgabe steht unten im Editor.

---

## 1. Fähigkeiten freischalten

Jede Spieler-Fähigkeit ist ein kurzer Text (ID) in `PlayerData.abilities`.

```gdscript
player.unlock_ability("fusion")        # Story schaltet Fusion frei
player.unlock_ability("zerschmettern") # Spitzhacke aus der Arena bekommen

if player.has_ability("fusion"):
    ...
```

Vorschlag für die IDs:

| ID | Woher | Wofür |
|---|---|---|
| `fusion` | Story (nach erster Ömer-Begegnung?) | Spieler fusioniert mit Monster |
| `zerschmettern` | Spitzhacke (Arena) | Felsen weg |
| `klettern` | Seilhaken | Wände hoch |
| `tauchen` | Tauchermaske | unter Wasser |

VMs sind Items (Relikt-Werkzeuge). Wenn der Spieler das Werkzeug bekommt, rufst du einfach `unlock_ability(...)` auf.

---

## 2. Der Spieler kämpft selbst

Regel: Der Spieler kämpft nur, **wenn kein Monster draußen ist** (alle K.O. oder freiwillig).

```gdscript
var mensch := MergeSystem.create_player_battler(player, player.level)
```

Das gibt ein Kampf-Dictionary wie bei einem Monster: `name`, `max_hp`, `attack`, `moves` usw.
Der Mensch hat keinen Typ und nur den Faustschlag (mit Timing).

Im Kampfablauf sieht das so aus:

```gdscript
if alle_monster_ko or spieler_will_selbst_kaempfen:
    aktiver_kaempfer = MergeSystem.create_player_battler(player, player.level)
```

---

## 3. Fusion

Fusion geht **jederzeit, ohne Leiste**, sobald der Spieler selbst kämpft, aber nur wenn die Story sie freigeschaltet hat.
Der Spieler bekommt den **Typ** und die **Attacken** des Monsters, dazu 40 % seiner Basiswerte.

```gdscript
if player.has_ability("fusion"):
    var merge := MergeSystem.new()
    merge.max_merge_turns = -1   # -1 = hält bis zum Kampfende ("letztes Aufbäumen")
    aktiver_kaempfer = merge.merge(player, monster, player.level)
```

- `merge_system.gd` stellt standardmäßig 10 Runden ein. Mit `max_merge_turns = -1` ist das aus.
- Fusion lösen: `merge.unmerge()`.
- Im Kampf-Menü zeigst du den Knopf „Fusion“ nur, wenn `player.has_ability("fusion")` stimmt.

---

## 4. Overworld-Hindernis mit Fähigkeit

Skript: `Scripts/Overworld/ability_obstacle.gd`

Szene bauen:
1. Neue Szene, Wurzel **StaticBody2D**, Skript `ability_obstacle.gd` anhängen.
2. Kind **Sprite2D** (Fels-Bild) und Kind **CollisionShape2D** (Rechteck in Tile-Größe).
3. Im Inspector `Required Ability` (z. B. `zerschmettern`) und `Blocked Text` setzen.
4. Als `fels.tscn` speichern und auf die Map ziehen.

Der Spieler ruft es auf, wenn er davor steht und „interact“ drückt, z. B. mit einem **RayCast2D** in Blickrichtung:

```gdscript
# im Spieler-Skript
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact") and $InteractRay.is_colliding():
        var ziel = $InteractRay.get_collider()
        if ziel.has_method("interact"):
            ziel.interact(player_data)
```

Damit der Fels nach dem Laden nicht wieder da ist, kommt später ein Story-Flag dazu (`GameState.set_flag(...)`, siehe Speicher-Tutorial).

---

## 5. `AbilityTemplate.gd` = Monster-Fähigkeiten

Achtung, Namensgleichheit: `AbilityData` (`Scripts/Abilities/AbilityTemplate.gd`) ist für **passive Fähigkeiten von Monstern** (z. B. „Feuer-Attacken +50 %“), nicht für den Spieler.

Neue Monster-Fähigkeit anlegen:
1. Im Dateisystem `Resources/Abilities/` → Rechtsklick → **Neu → Ressource → AbilityData**.
2. `AbilityName`, `Description` und z. B. `BoostMoveType = FIRE`, `MoveTypeBoost = 1.5` setzen.
3. Im Monster (`MonsterData`) unter `abilities` eintragen.

Im Schadensrechner benutzt du dann:

```gdscript
for ability in monster.abilities:
    schaden *= ability.get_outgoing_damage_multiplier(move.MoveType, ist_physisch)
```

---

## Noch offen

- Fusion mit einem K.O.-Monster erlaubt? (Vorschlag: ja)
- Wann genau wird Fusion freigeschaltet?
- Mensch und Fusion rechnen Werte mit verschiedenen Formeln (Mensch Level 1: 13 HP, mit Fuego: 124 HP). Das sollte vereinheitlicht werden, sobald der Spieler eigene EP bekommt.
