extends TileMapLayer

@export var required_value: int = 2

func _process(_delta):
	visible = GameState.valoare_globala >= required_value
