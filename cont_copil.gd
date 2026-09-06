extends VBoxContainer

var sprite_sheet := preload("res://assets/animals1.png")
var cols := 7
var rows := 3
var child_name: String
signal clicked(id, nume)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func setup(nume: String, avatar: int):
	$Label.text = nume
	child_name = nume
	var sheet_size = sprite_sheet.get_size()
	var cell_size = sheet_size / Vector2(cols, rows)
	var row = int(avatar / cols)
	var col = avatar % cols
	var atlas = AtlasTexture.new()
	atlas.atlas = sprite_sheet
	atlas.region = Rect2(Vector2(col, row) * cell_size, cell_size)
	$PanelContainer/TextureButton.texture_normal = atlas
	$PanelContainer/TextureButton.texture_pressed = atlas
	$PanelContainer/TextureButton.texture_hover = atlas
	$PanelContainer/TextureButton.texture_focused = atlas
	$PanelContainer/TextureButton.texture_disabled = atlas
	$PanelContainer/TextureButton.pressed.connect(_on_pressed)
	
func _on_pressed():
	emit_signal("clicked", child_name)
