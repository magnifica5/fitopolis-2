extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		self.text = str(int(data.scor))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_area_2d_modificare() -> void:
	#var score = Globals.citeste_score()
	#self.text = str(int(score))
#
#
#func _on_area_2d_2_modificare() -> void:
	#var score = Globals.citeste_score()
	#self.text = str(int(score))
#
#
#func _on_area_2d_3_modificare() -> void:
	#var score = Globals.citeste_score()
	#self.text = str(int(score))
#
#
#func _modificare() -> void:
	#var score = Globals.citeste_score()
	#self.text = str(int(score))
