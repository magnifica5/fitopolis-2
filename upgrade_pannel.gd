extends TextureRect

@onready var label = $Sprite2D/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_upgrade() -> void:
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null:
		var data = result.data
		data = data[0]
		var score = data.scor
		var text = int(label.text)
		if score >= text:
			score -= text
			print(score)
			var query2 = SupabaseQuery.new().from("children").update({"scor": int(score)}).eq("connection_code",Globals.code)
			var task2 = Supabase.database.query(query2)
			var result2 = await task2.completed
			if result2.error == null:
				Globals.adauga_scor(int(score))
				print("scor modificat")
				GameState.valoare_globala += 1
				GameState.level_updated.emit()
				self.visible = false
				# Salvează valoarea nouă pe disc!
				GameState.salveaza_jocul()
				get_tree().reload_current_scene()
