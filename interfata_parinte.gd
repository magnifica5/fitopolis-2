extends Control

@onready var rows_parent = $CanvasLayer2/VBoxContainer

var child_btn_scene = preload("res://kids_account.tscn")
var dashboard_scene = "res://dashboard.tscn"
var login_child_scene = "res://login_child.tscn"


func _ready() -> void:
	preload_scene(dashboard_scene)
	preload_scene(login_child_scene)
	await SyncManager.load_parent_data()
	load_child_account()
	# Salvam o copie a copiilor incarcati local.
	var copii_initiali = Globals.copii.duplicate(true)
	# Sincronizam lista cu Supabase.
	await SyncManager.sync_data_parents()
	var copii_actuali = Globals.copii
	# Reincarcam butoanele daca lista s-a modificat.
	if copii_actuali != copii_initiali:
		load_child_account()


func preload_scene(path: String):
	ResourceLoader.load_threaded_request(path)


func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null


func load_child_account():
	var rows = rows_parent.get_children()
	# Stergem butoanele vechi.
	for row in rows:
		for n in row.get_children():
			if n.name != "VBoxContainer_Adauga":
				n.queue_free()
	# Asteptam eliminarea nodurilor.
	await get_tree().process_frame
	var current_row_idx = 0
	# Globals.copii este acum un Dictionary.
	for cod in Globals.copii:
		var data = Globals.copii[cod]
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
				str(data.get("username", "")),
				int(data.get("avatar_number", 0)),
				str(cod)
			)
		else:
			print("Nu mai exista spatiu in randurile create!")


func creeaza_buton_copil(
	target_row: HBoxContainer,
	nume: String,
	avatar: int,
	cod: String
):
	var btn = child_btn_scene.instantiate()
	target_row.add_child(btn)

	btn.setup(nume, avatar)

	# Transmitem si codul unic al copilului.
	btn.clicked.connect(_on_child_select.bind(cod))


func _on_child_select(nume: String, cod: String):
	Globals.username = nume
	# Retinem codul copilului selectat.
	Globals.connection_coded = cod
	var ready = get_scene(dashboard_scene)
	if ready:
		get_tree().change_scene_to_packed(ready)


func _on_adauga_copil() -> void:
	var ready = get_scene(login_child_scene)
	if ready:
		get_tree().change_scene_to_packed(ready)
