extends Control


@onready var rows_parent = $CanvasLayer2/VBoxContainer
var child_btn_scene = preload("res://kids_account.tscn")

func _ready() -> void:
	load_child_account()

func load_child_account():
	# obținem toate rândurile 
	var rows = rows_parent.get_children()
	# curățăm toate rândurile de butoane vechi
	for row in rows:
		for n in row.get_children():
			if n.name != "VBoxContainer_Adauga":
				n.queue_free()
	# luam datele de la Supabase
	var parent = Supabase.auth.client
	if parent == null: return
	var query = SupabaseQuery.new().from("children").select().eq("parent_id", parent.id) # selecteaza toate coloanele in care avem id al acestui parinte
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null:
		# folosim un index pentru a ști în ce rând punem butonul
		var current_row_idx = 0
		for data in result.data:
			# verificam daca randul curent este plin (6 elemente)
			while current_row_idx < rows.size() and rows[current_row_idx].get_child_count() >= 6:
				current_row_idx += 1
			# daca mai avem disponibilitate, completam
			if current_row_idx < rows.size():
				creeaza_buton_copil(rows[current_row_idx], data.username, data.avatar_number)
			else:
				print("Nu mai există spațiu în rândurile create!")

func creeaza_buton_copil(target_row: HBoxContainer, nume: String, avatar: int):
	var btn = child_btn_scene.instantiate()
	target_row.add_child(btn)
	btn.setup(nume, avatar) # setup umple labelul si texturile butonului
	btn.clicked.connect(_on_child_select)
	
func _on_child_select(nume: String):
	Globals.username = nume
	get_tree().change_scene_to_file("res://dashboard.tscn")
	
func _on_adauga_copil() -> void:
	get_tree().change_scene_to_file("res://login_child.tscn")
