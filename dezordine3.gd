extends TileMapLayer # sau Node2D / CanvasItem

@export var x: int 

func _ready() -> void:
	GameState.level_updated.connect(actualizeaza_vizibilitate)
	x=3
	actualizeaza_vizibilitate()

func actualizeaza_vizibilitate() -> void:
	visible = false
	if x >= 3:
		visible = true
