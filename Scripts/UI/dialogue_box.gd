extends CanvasLayer

## PLATZHALTER - Textbox für NPCs, Schilder und Story.
## Später als Autoload "DialogueBox" oder als Teil der Overworld-Szene.

signal finished

func show_lines(lines: Array[String], speaker := "") -> void:
	# TODO:
	# Spieler-Bewegung sperren
	# für jede Zeile: Buchstabe für Buchstabe einblenden (Schreibmaschine)
	#   "interact" drücken -> Zeile sofort ganz zeigen, nochmal -> nächste Zeile
	# am Ende: Box ausblenden, Bewegung freigeben, finished.emit()
	pass
