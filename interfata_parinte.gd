extends Control

@onready var container = $CanvasLayer2/VBoxContainer/HBoxContainer
var child_btn_scene = preload("res://kids_account.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_child_account()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func load_child_account():
	for n in container.get_children():
		if n.name != "VBoxContainer_Adauga": # Pune un nume specific butonului de adăugare
			n.queue_free()
	var parent = Supabase.auth.client
	if parent == null: return
	var query = SupabaseQuery.new().from("children").select().eq("parent_id", parent.id)
	var task = Supabase.database.query(query)
	var result = await task.completed

	if result.error == null:
		for data in result.data:
			creeaza_buton_copil(data.username, data.avatar_number)

func creeaza_buton_copil(nume: String, avatar: int):
	var btn = child_btn_scene.instantiate()
	container.add_child(btn)
	#container.move_child(btn, 0) # Îl pune la început, înaintea butonului "Adaugă"
	btn.setup(nume, avatar)

func _on_adauga_copil() -> void:
	get_tree().change_scene_to_file("res://login_child.tscn")
