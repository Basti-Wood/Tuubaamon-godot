extends PuzzleElement

## PLATZHALTER - Loch im Boden. Ein Fels oder Block hineinschieben füllt es (AN) und macht
## das Feld begehbar. Auf einer oberen Etage: Fels fällt eine Etage tiefer (Siegesstraße-Rätsel).

@export var grid: NodePath
@export var drop_target: NodePath          # optional: Marker3D auf der Etage darunter, wo der Fels landet

func _ready() -> void:
	super()
	# TODO: eigenes Feld beim PuzzleGrid als besetzt anmelden (grid.occupy(cell, self))
	pass

func fill(_boulder: Node3D) -> void:
	# TODO:
	# Fels-Animation: hineinrutschen und absinken, Staubwolke
	# if drop_target: Fels dort wieder auftauchen lassen (auf der unteren Etage weiterbenutzbar)
	# else: Fels entfernen
	# grid.release(cell) -> Feld wieder frei; set_active(true)
	pass

func _apply_state(_animate: bool) -> void:
	# TODO: AN = Loch zu (Boden-Sprite), AUS = Loch offen (Kollision, damit der Spieler nicht reinfällt)
	pass
