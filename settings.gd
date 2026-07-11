extends Control

@onready var avatar_final = $PanelContainer/TextureButton
@onready var panel_button = $PanelContainer
@onready var username = $LineEdit
@onready var email = $LineEdit2
@onready var termeni = $Panel
@onready var politica = $Panel2
@onready var panel = $PopupPanel
@onready var grid = $PopupPanel/GridContainer
@onready var erori_email = $LineEdit2/Label
@onready var succes = $Panel4
@onready var label_succes = $Panel4/Label
signal start_eye
var email_final
var sprite_sheet := preload("res://assets/animals.png")
var cols := 7
var rows := 3
var id_copil
func _ready() -> void:
	succes.hide()
	termeni.hide()
	politica.hide()
	panel.hide()
	var parent = Supabase.auth.client
	if parent == null: 
		print("Eroare: Clientul Supabase nu este autentificat.")
		return
	var query = SupabaseQuery.new().from("children").select().eq("username", Globals.username)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		id_copil = data.id
		Globals.selected_index = data.avatar_number
		var avatar_idx = int(data.avatar_number)
		_update_avatar_visual(avatar_idx)
		username.text = data.username
		username.editable = false
		email.text = parent.email
		email_final = parent.email
		email.editable = false
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
	var new_username = username.text.strip_edges()
	var query = SupabaseQuery.new().from("children").update({"username": new_username, "avatar_number": Globals.selected_index}).eq("id", id_copil)
	var task = Supabase.database.query(query)
	var res = await task.completed
	print(res.data)
	if res.error == null:
		print("succes")
		Globals.username = new_username
		username.editable = false
	else:
		print(res.error.message)
	var noul_email = email.text.strip_edges()
	if erori_email.text == "":
		var email_schimbat = (noul_email != email_final)
		if email_schimbat:
			var task1 = Supabase.auth.update_email(noul_email)
			var res1 = await task1.completed
			_handle_auth_result(res1, "Email")
	else:
		return
		
func _handle_auth_result(res, tip):
	if res.error == null:
		print("Succes actualizare: ", tip)
		if tip == "Email":
			email_final = email.text.strip_edges()
			print("Verifică inbox-ul pentru confirmare.")
			email.editable = false
			label_succes.text = '''Verifica fosta si
actuala adresa de 
mail pentru a
finaliza modificarile'''
			succes.show()
	else:
		print("Eroare la ", res.error.message)


func _close_succes() -> void:
	succes.hide()
	#get_tree().reload_current_scene()
