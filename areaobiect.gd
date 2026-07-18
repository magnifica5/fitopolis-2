extends Area2D

@export var poza: Texture2D

@onready var sprite := $Sprite2D

@onready var collision := $CollisionShape2D

var dragging := false
var drag_offset := Vector2.ZERO

func _ready():
	if Itemshop.textura_salvata != null:
		sprite.texture = Itemshop.textura_salvata
		sprite.scale = Vector2(2, 2)
	else:
		sprite.texture = poza
		sprite.scale = Vector2.ONE

	Itemshop.schimba_poza_mouse.connect(schimba_textura)
	Itemshop.schimba_poza_mouse.connect(_on_schimba_poza)

	if Itemshop.textura_salvata != null:
		_on_schimba_poza(Itemshop.textura_salvata)

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = global_position - get_global_mouse_position()
			else:
				dragging = false

func _on_schimba_poza(_textura: Texture2D):
	get_parent().get_node("CanvasLayer/return").visible = true
	get_parent().get_node("CanvasLayer/TextureButton").visible = false
	get_parent().get_node("CanvasLayer/TextureButton2").visible = false
	get_parent().get_node("CanvasLayer/TextureButton3").visible = false
	get_parent().get_node("CanvasLayer/TextureButton4").visible = true

func actualizeaza_coliziunea():
	if sprite.texture == null:
		return

	var shape = collision.shape as RectangleShape2D
	shape.size = sprite.texture.get_size() * sprite.scale
func schimba_textura(textura_noua: Texture2D) -> void:
	if textura_noua != null:
		sprite.texture = textura_noua
		sprite.scale = Vector2(6, 6)
	else:
		sprite.texture = poza
		sprite.scale = Vector2.ONE
func _input_event2(_viewport, event, _shape_idx):
	print("CLICK")
