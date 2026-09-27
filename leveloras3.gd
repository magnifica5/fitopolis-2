extends TileMapLayer

@export var required_value: int = 1
@export var conditie_ascundere: bool = false # Condiția ta suplimentară
 
func _process(_delta):
	# Daca conditia este true -> devine invisible (false)
	# Altfe -> verifica conditia normala cu required_value
	if conditie_ascundere:
		visible = false
	else:
		visible = GameState.valoare_globala >= required_value
