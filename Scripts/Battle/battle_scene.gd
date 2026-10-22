extends Node3D

## PLATZHALTER - die richtige Kampfszene (ersetzt später die Debug-Kampfszene).
## 2.5D, Kamera schräg von oben-seitlich (siehe battle_camera.gd).
## Aufbau von Szene/Battle/battle_scene.tscn:
##   BattleScene (Node3D, dieses Skript)
##   ├── Arena (MeshInstance3D / kleine 3D-Bühne passend zur Map)
##   ├── PlayerSlot (Marker3D)   links vorne
##   ├── EnemySlot (Marker3D)    rechts hinten
##   ├── BattleCamera (Camera3D, battle_camera.gd)
##   └── BattleHUD (CanvasLayer, Scripts/UI/battle_hud.gd)
## Die Logik (Schaden, Reihenfolge) kommt aus BattleSystem/DamageCalculator,
## das Timing aus ActionCommand (Scripts/Battle/action_command.gd).

signal battle_finished(result: String)    # "win", "lose", "caught", "fled"

# TODO: var player_team: Array[MonsterInstance]
# TODO: var enemy_team: Array[MonsterInstance]
# TODO: var is_trainer_battle := false

func setup(player_team: Array, enemy_team: Array, is_trainer: bool) -> void:
	# TODO: Teams speichern, Sprite3D der ersten Monster auf die Slots setzen, HUD füllen
	pass

func _run_turn() -> void:
	# TODO: Ablauf einer Runde (Mario-&-Luigi-Stil):
	# 1. HUD zeigt Menü: Attacke / Item / Wechseln / Fangen / Fliehen
	# 2. Gegner wählt per EnemyAI
	# 3. Reihenfolge nach Priorität und Initiative
	# 4. Für jeden Angriff:
	#      Angreifer läuft/springt zum Ziel (Tween auf Sprite3D)
	#      ActionCommand starten:
	#         Spieler greift an  -> Spieler drückt im Moment des Aufpralls -> Angriffs-Multiplikator
	#         Gegner greift an   -> Spieler drückt zum Ausweichen/Blocken  -> Verteidigungs-Multiplikator
	#      Schaden mit DamageCalculator berechnen, Zahl über dem Ziel einblenden, Kamera kurz wackeln
	# 5. K.O. prüfen -> Monster wechseln, oder Spieler kämpft selbst / Fusion (siehe MergeSystem)
	# 6. Kampf vorbei? -> battle_finished.emit(...)
	pass
