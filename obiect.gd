extends Sprite2D

@export var poza: Texture2D

func _ready():
	# Verificăm dacă jucătorul a schimbat deja poza în Itemshop
	if Itemshop.textura_salvata != null:
		texture = Itemshop.textura_salvata
	else:
		texture = poza # Poza ta default dacă nu s-a cumpărat/schimbat nimic
		
	Itemshop.schimba_poza_mouse.connect(schimba_textura)

func _process(delta):
	global_position = get_global_mouse_position()

func schimba_textura(textura_noua: Texture2D) -> void:
	texture = textura_noua
