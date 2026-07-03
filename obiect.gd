extends Sprite2D

@export var poza: Texture2D

func _ready():
	# Verificăm dacă jucătorul a schimbat deja poza în Itemshop
	if Itemshop.textura_salvata != null:
		texture = Itemshop.textura_salvata
	else:
		texture = poza # Poza ta default dacă nu s-a cumpărat/schimbat nimic
		
	Itemshop.schimba_poza_mouse.connect(schimba_textura)
	Itemshop.schimba_poza_mouse.connect(_on_schimba_poza)

	if Itemshop.textura_salvata != null:
		_on_schimba_poza(Itemshop.textura_salvata)


func _on_schimba_poza(_textura: Texture2D):
	get_parent().get_node("CanvasLayer/return").visible = true
	get_parent().get_node("CanvasLayer/TextureButton").visible = false
	get_parent().get_node("CanvasLayer/TextureButton2").visible = false
	get_parent().get_node("CanvasLayer/TextureButton3").visible = false


func _process(delta):
	global_position = get_global_mouse_position()

func schimba_textura(textura_noua: Texture2D) -> void:
	if textura_noua != null:
		texture = textura_noua
	else:
		texture = poza # revine la textura implicită
