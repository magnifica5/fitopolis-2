extends Control


@onready var rows_parent = $CanvasLayer2/VBoxContainer
var child_btn_scene = preload("res://kids_account.tscn")
var dashboard_scene = "res://dashboard.tscn"
var login_child_scene = "res://login_child.tscn"


func _ready() -> void:
	preload_scene(dashboard_scene)
	preload_scene(login_child_scene)

	SyncManager.load_parent_data()
	load_child_account()

	var copii_initiali = normalizeaza_copii(Globals.copii)

	await SyncManager.sync_data_parents()

	var copii_actuali = normalizeaza_copii(Globals.copii)

	if copii_actuali != copii_initiali:
		load_child_account()


func normalizeaza_copii(copii: Array) -> Array[Dictionary]:
	var rezultat: Array[Dictionary] = []

	for copil in copii:
		rezultat.append({
			"username": str(copil.get("username", "")),
			"avatar_number": int(copil.get("avatar_number", 0))
		})

	return rezultat

func preload_scene(path: String):
	ResourceLoader.load_threaded_request(path)

func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null

#func load_child_account():
	#var rows = rows_parent.get_children()
	## curățăm toate rândurile de butoane vechi
	#for row in rows:
		#for n in row.get_children():
			#if n.name != "VBoxContainer_Adauga":
				#n.queue_free()
	## luam datele de la Supabase
	##var parent = Supabase.auth.client
	##if parent == null: return
	##var query = SupabaseQuery.new().from("children").select().eq("parent_id", parent.id) # selecteaza toate coloanele in care avem id al acestui parinte
	##var task = Supabase.database.query(query)
	##var result = await task.completed
	##if result.error == null:
		## folosim un index pentru a ști în ce rând punem butonul
	#var current_row_idx = 0
	#for data in Globals.copii:
		## verificam daca randul curent este plin (6 elemente)
		#while current_row_idx < rows.size() and rows[current_row_idx].get_child_count() >= 6:
			#current_row_idx += 1
		## daca mai avem disponibilitate, completam
		#if current_row_idx < rows.size():
			#creeaza_buton_copil(rows[current_row_idx], data.username, data.avatar_number)
		#else:
			#print("Nu mai există spațiu în rândurile create!")


func load_child_account():
	var rows = rows_parent.get_children()

	# Stergem butoanele vechi
	for row in rows:
		for n in row.get_children():
			if n.name != "VBoxContainer_Adauga":
				n.queue_free()

	# Asteptam eliminarea nodurilor marcate pentru stergere
	await get_tree().process_frame

	var current_row_idx = 0

	for data in Globals.copii:
		while current_row_idx < rows.size():
			var row = rows[current_row_idx]
			var numar_copii = 0

			for n in row.get_children():
				if n.name != "VBoxContainer_Adauga":
					numar_copii += 1

			if numar_copii < 6:
				break

			current_row_idx += 1

		if current_row_idx < rows.size():
			creeaza_buton_copil(
				rows[current_row_idx],
				data["username"],
				int(data["avatar_number"])
			)
		else:
			print("Nu mai exista spatiu in randurile create!")


func creeaza_buton_copil(target_row: HBoxContainer, nume: String, avatar: int):
	var btn = child_btn_scene.instantiate()
	target_row.add_child(btn)
	btn.setup(nume, avatar) # setup umple labelul si texturile butonului
	btn.clicked.connect(_on_child_select)
	
func _on_child_select(nume: String):
	Globals.username = nume
	var ready = get_scene(dashboard_scene)
	if ready:
		get_tree().change_scene_to_packed(ready)
	
func _on_adauga_copil() -> void:
	var ready = get_scene(login_child_scene)
	if ready:
		get_tree().change_scene_to_packed(ready)
