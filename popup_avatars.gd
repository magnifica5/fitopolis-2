extends CanvasLayer
@onready var buton_profil = $PanelContainer/TextureButton
@onready var edit_buton_profil = $TextureButton2
@onready var panel_button = $PanelContainer
@onready var panel = $PopupPanel
@onready var grid = $PopupPanel/GridContainer
# Called when the node enters the scene tree for the first time.
var sprite_sheet := preload("res://assets/animals1.png")
var cols := 7
var rows := 3
func _ready() -> void:
	build_avatar_grid()
	buton_profil.pressed.connect(_open_popup)
	edit_buton_profil.pressed.connect(_open_popup)
	panel.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func build_avatar_grid():
	for photo in grid.get_children():
		photo.queue_free()
	
	var sheet_size = sprite_sheet.get_size()
	var cell_size = sheet_size / Vector2(cols, rows)
	var index = 0
	
	for i in range(rows):  
		for j in range(cols):
			var atlas = AtlasTexture.new()
			atlas.atlas = sprite_sheet
			atlas.region = Rect2(Vector2(j, i) * cell_size, cell_size)
			var btn = TextureButton.new()
			btn.texture_normal = atlas
			btn.pressed.connect(_select_avatar.bind(index))
			grid.add_child(btn)
			index += 1

			
func _open_popup():
	panel.popup_centered()
	panel.show()

func _select_avatar(index: int):
	Globals.selected_index = index
	var btn = grid.get_child(index)
	buton_profil.texture_normal = btn.texture_normal
	panel.hide()
