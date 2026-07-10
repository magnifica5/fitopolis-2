extends Control

@onready var avatar_final = $PanelContainer/TextureButton
@onready var panel_button = $PanelContainer
@onready var username = $LineEdit
@onready var email = $LineEdit2
@onready var password = $LineEdit3
@onready var termeni = $Panel
@onready var politica = $Panel2
@onready var panel = $PopupPanel
@onready var grid = $PopupPanel/GridContainer
@onready var resetare1 = $resetare_parola1
@onready var resetare2 = $resetare_parola2
@onready var resetare3 = $resetare_parola3

var sprite_sheet := preload("res://assets/animals.png")
var cols := 7
var rows := 3

func _ready() -> void:
	termeni.hide()
	politica.hide()
	panel.hide()
	password.secret = true
	var parent = Supabase.auth.client
	if parent == null: 
		print("Eroare: Clientul Supabase nu este autentificat.")
		return
	var query = SupabaseQuery.new().from("children").select().eq("username", Globals.username)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		var avatar_idx = int(data.avatar_number)
		_update_avatar_visual(avatar_idx)
		username.text = data.username
		username.editable = false
		email.text = parent.email
		email.editable = false
		password.text = "********"
		password.editable = false
	else:
		var err_msg = result.error.message if result.error else "Nu s-au găsit date."
		print("Eroare la încărcarea datelor: ", err_msg)

func _catre_termeni() -> void:
	termeni.show()

func _catre_politica() -> void:
	politica.show()

func _close_termeni() -> void:
	termeni.hide()

func _close_politica() -> void:
	politica.hide()

func _on_edit_username() -> void:
	username.editable = true

func _on_edit_email() -> void:
	email.editable = true

func _on_edit_parola() -> void:
	resetare1.show()

func _on_edit_avatar() -> void:
	build_avatar_grid()
	panel.popup_centered() # popup_centered afișează automat panel-ul

func build_avatar_grid(): # pregateste fiecare buton cu animal care apare in popup
	for photo in grid.get_children():
		grid.remove_child(photo)
		photo.queue_free()
	grid.columns = cols
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
			btn.ignore_texture_size = true
			btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			btn.custom_minimum_size = Vector2(200, 200)
			btn.pressed.connect(_select_avatar.bind(atlas, index))
			grid.add_child(btn)
			index += 1

func _select_avatar(atlas_texture: AtlasTexture, index: int): # ce se intampla cand apas pe un buton din popup
	Globals.selected_index = index
	avatar_final.texture_normal = atlas_texture
	avatar_final.texture_pressed = atlas_texture
	avatar_final.texture_hover = atlas_texture
	avatar_final.texture_focused = atlas_texture
	panel.hide()

func _update_avatar_visual(index: int): # ruleaza la inceput ca sa mi puna animalul cu indexul de pe server
	var sheet_size = sprite_sheet.get_size()
	var cell_size = sheet_size / Vector2(cols, rows)
	var row = int(index / cols)
	var col = index % cols
	var atlas = AtlasTexture.new()
	atlas.atlas = sprite_sheet
	atlas.region = Rect2(Vector2(col, row) * cell_size, cell_size)
	avatar_final.texture_normal = atlas
	avatar_final.texture_pressed = atlas
	avatar_final.texture_hover = atlas
	avatar_final.texture_focused = atlas


func _on_salveaza() -> void:
	pass # Replace with function body.
