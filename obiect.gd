extends Sprite2D

@export var poza: Texture2D

func _ready():
	texture = poza

func _process(delta):
	global_position = get_global_mouse_position()
