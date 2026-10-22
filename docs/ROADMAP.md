# Tuubaamon: Roadmap

Stand: 2026-10-22. Die Spielregeln stehen in den Design-Notizen (Obsidian-Vault / `design/spielmechaniken.md`).

## Entscheidungen

- Stil: **2.5D**. 3D-Welt, Figuren und Monster als 2D-Sprites (Billboards). Overworld-Kamera schräg von oben.
- Kampf: eigene 3D-Szene, Kamera erhöht von der Seite. Jede Attacke hat ein Timing mit 5 Stufen (Angriff und Verteidigung).
- Fangen mit Schmuck/Amuletten, VMs sind Items, Team max. 6, Fusion Spieler + Monster als "letzter Kampf".

## Stand

| System | Status | Dateien |
|---|---|---|
| Typentabelle (18 Typen) | ✅ fertig (Licht-Typ fehlt noch) | `Scripts/Battle/type_chart.gd` |
| Schadensberechnung | ✅ fertig | `Scripts/Battle/damage_calculator.gd` |
| Kampf-Ablauf | 🟡 Grundgerüst, keine KI/Wechsel | `Scripts/Battle/battle_system.gd` |
| Timing (5 Stufen) | 🟡 Prototyp in Test | `Scripts/Battle/action_command.gd`, `Szene/Prototype/` |
| Altes QTE-System (4 Stufen) | 🟡 wird vom neuen Timing abgelöst | `Scripts/Battle/qte_system.gd` |
| Fusion | 🟡 noch mit 10-Runden-Limit | `Scripts/Battle/merge_system.gd` |
| Daten-Vorlagen | ✅ fertig | `Scripts/Monster`, `Move`, `Item`, `Abilities`, `StatusEffects` |
| Einstellungen + Optionsmenü | ✅ fertig | `Scripts/ConfigManager.gd`, `Scripts/Main menue/` |
| Hauptmenü | 🟡 Aussehen fertig, "Neues Spiel"/"Weiterspielen" fehlen | `Szene/main menue/` |
| Gefangenes Monster (MonsterInstance) | 🔲 Platzhalter | `Scripts/Monster/monster_instance.gd` |
| Spielzustand, Speichern, Szenenwechsel | 🔲 Platzhalter | `Scripts/Core/` |
| Overworld (Spieler, Kamera, Gras, Türen, NPCs, VMs) | 🔲 Platzhalter | `Scripts/Overworld/` |
| Kampfszene 2.5D (Kamera, HUD, KI, Fangen) | 🔲 Platzhalter | `Scripts/Battle/battle_scene.gd` usw., `Scripts/UI/battle_hud.gd` |
| Menüs (Team, Inventar, Dialog, Pause) | 🔲 Platzhalter | `Scripts/UI/` |
| Amulette (Fangen, Upgrades) | 🔲 Platzhalter | `Scripts/Item/amulet_data.gd` |

## Nächste Schritte (Reihenfolge)

1. **Kampfkern vereinheitlichen:** BattleSystem als einzige Logik, Timing aus ActionCommand (5 Stufen), Glück-Stat für Krits, Licht-Typ, Fusion ohne Rundenlimit.
2. **MonsterInstance** bauen (Level, KP, Attacken, Amulett). Grundlage für Team, Fangen und Speichern.
3. **Erste 2.5D-Map:** Spieler läuft herum, Kamera folgt, hohes Gras startet einen Kampf.
4. **2.5D-Kampfszene** mit Kamera von oben-seitlich, ersetzt die Debug-Kampfszene.
5. **Fangen mit Amuletten** + Team-Menü.
6. Speichern/Laden, Dialoge, NPCs/Trainer, erste Arena.
7. Inhalte: mehr Monster (Community-Mitglieder), Attacken, Maps, Dungeons.

Wie man einzelne Dinge hinzufügt: siehe [ANLEITUNG.md](ANLEITUNG.md).
