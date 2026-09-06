extends TextureRect
@onready var label = $Sprite2D/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_upgrade() -> void:
	$TextureButton/AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	Globals.code = Globals.citeste_code()
	var cost_item = int(label.text)
	
	# 2. Prima interogare: Verificăm scorul
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	
	if result.error != null:
		print("Eroare la citirea scorului: ", result.error)
		return
		
	var data = result.data
	# 3. Validăm că am primit date pentru a evita crash-ul
	if data == null or data.is_empty():
		print("Eroare: Nu s-a găsit utilizatorul cu acest cod.")
		return
		
	var score = data[0].scor
	
	if score >= cost_item:
		var scor_nou = score - cost_item
		var query2 = SupabaseQuery.new().from("children").update({"scor": int(scor_nou)}).eq("connection_code", Globals.code)
		var task2 = Supabase.database.query(query2)
		var result2 = await task2.completed
		if result2.error == null:
			Globals.adauga_scor(scor_nou)
		GameState.valoare_globala += 1
		GameState.level_updated.emit()
		self.visible = false
		# Salvează valoarea nouă pe disc!
		GameState.salveaza_jocul()
		get_tree().reload_current_scene()
