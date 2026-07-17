extends Sprite2D

@export var poza: Texture2D

func _ready():
	if Itemshop.textura_salvata != null:
		texture = Itemshop.textura_salvata
		scale = Vector2(2, 2) # mărimea preview-ului
	else:
		texture = poza
		scale = Vector2.ONE

	Itemshop.schimba_poza_mouse.connect(schimba_textura)
	Itemshop.schimba_poza_mouse.connect(_on_schimba_poza)

	if Itemshop.textura_salvata != null:
		_on_schimba_poza(Itemshop.textura_salvata)

func _on_schimba_poza(_textura: Texture2D):
	get_parent().get_node("CanvasLayer/return").visible = true
	get_parent().get_node("CanvasLayer/TextureButton").visible = false
	get_parent().get_node("CanvasLayer/TextureButton2").visible = false
	get_parent().get_node("CanvasLayer/TextureButton3").visible = false
	get_parent().get_node("CanvasLayer/TextureButton4").visible = true

func _process(_delta):
	global_position = get_global_mouse_position()

func schimba_textura(textura_noua: Texture2D) -> void:
	if textura_noua != null:
		texture = textura_noua
		scale = Vector2(6, 6) # aceeași scară ca în _ready
	else:
		texture = poza
		scale = Vector2.ONE
