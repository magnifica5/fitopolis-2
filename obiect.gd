extends Sprite2D

@export var poza: Texture2D

var dragging := false
var drag_offset := Vector2.ZERO

func _ready():
	if Itemshop.textura_salvata != null:
		texture = Itemshop.textura_salvata
		scale = Vector2(2, 2)
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
	if texture == null:
		return

	var mouse_pos = get_global_mouse_position()

	# Calculăm corect zona sprite-ului centrat
	var rect = Rect2(
		global_position - (texture.get_size() * scale) / 2,
		texture.get_size() * scale
	)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Dacă nu mișcam deja și am dat click pe sprite
		if !dragging and rect.has_point(mouse_pos):
			print("START DRAG")
			dragging = true
			drag_offset = global_position - mouse_pos
			Itemshop.dragging_item = true
			
			# Oprim camera din mișcare în mod explicit
			var cam = get_viewport().get_camera_2d()
			if cam:
				cam.dragging = false

		# Dacă deja îl mișcăm, îi actualizăm poziția
		if dragging:
			global_position = mouse_pos + drag_offset
	else:
		# AICI oprim drag-ul, doar când mouse-ul NU mai este apăsat
		if dragging:
			print("STOP DRAG")
			dragging = false
			Itemshop.dragging_item = false

func schimba_textura(textura_noua: Texture2D) -> void:
	if textura_noua != null:
		texture = textura_noua
		scale = Vector2(6, 6)
	else:
		texture = poza
		scale = Vector2.ONE
