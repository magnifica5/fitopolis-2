extends TileMapLayer # sau Node2D / CanvasItem

@export var x: int 

func _ready() -> void:
	actualizeaza_vizibilitate()

func actualizeaza_vizibilitate() -> void:
	if x == 3:
		visible = true
