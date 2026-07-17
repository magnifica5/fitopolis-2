extends Node
var complete_trezire = 0
var complete_ex = 0
var complete_dejun = 0
var complete_pranz = 0
var complete_ex2 = 0
var complete_cina = 0
var complete_somn = 0
var score = 0
var missed = 0
var nr_day = 0
var date
var is_data_loaded = false
func save_progress():
	if not is_data_loaded:
		print("Salvare anulată: Datele încă nu s-au încărcat din server!")
		return
	var data = {
		"trezire": int(complete_trezire),
		"ex1": int(complete_ex),
		"masa_dimineata": int(complete_dejun),
		"masa_pranz": int(complete_pranz),
		"ex2": int(complete_ex2),
		"masa_seara": int(complete_cina),
		"somn": int(complete_somn),
		"missed": int(missed)
	}
	print("ne pregatim de update")
	var task_upsert = Supabase.database.query(SupabaseQuery.new().from("progres_copil").update(data).eq("connection_code", Globals.citeste_code()))
	var result = await task_upsert.completed
	if result.error == null:
		print("success")
	else:
		print(result.error.message)
	#var json_string = JSON.stringify(data)
	#var file = FileAccess.open("user://progress.json", FileAccess.WRITE)
	#file.store_string(json_string)
	#file.close()

func load_progress():
	is_data_loaded = false
	var query = SupabaseQuery.new().from("progres_copil").select().eq("connection_code", Globals.citeste_code())
	var task_upsert = Supabase.database.query(query)
	var result = await task_upsert.completed
	if result.error == null:
		var data = result.data
		if data.size() > 0:
			data = data[0]
			complete_trezire = data.trezire
			complete_ex = data.ex1
			complete_dejun = data.masa_dimineata
			complete_pranz = data.masa_pranz
			complete_ex2 = data.ex2
			complete_cina = data.masa_seara
			complete_somn = data.somn
			missed = data.missed
		is_data_loaded = true
	#if not FileAccess.file_exists("user://progress.json"):
		#return  
#
	#var file = FileAccess.open("user://progress.json", FileAccess.READ)
	#var content = file.get_as_text()
	#file.close()
#
	#var result = JSON.parse_string(content)
#
	#if result:
		#complete_trezire = result.get("trezire", 0)
		#complete_ex = result.get("ex", 0)
		#complete_dejun = result.get("dejun", 0)
		#complete_pranz = result.get("pranz", 0)
		#complete_ex2 = result.get("ex2", 0)
		#complete_cina = result.get("cina", 0)
		#complete_somn = result.get("somn", 0)
		#score = result.get("score", 0)
		#missed = result.get("missed", 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_progress()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_choose_activity():
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.citeste_code())
	print(Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		var trezire = change_type(data.trezire)
		var ex_dimineata = change_type(data.ex1)
		var dejun = change_type(data.masa_dimineata)
		var pranz = change_type(data.masa_pranz)
		var ex_seara = change_type(data.ex2)
		var cina = change_type(data.masa_seara)
		var somn = change_type(data.culcare)
		var ora_curenta = Time.get_datetime_dict_from_system()
		var mins = ora_curenta.hour * 60 + ora_curenta.minute
		print(mins)
		print(pranz)
		if (not(mins >= trezire and mins <= trezire + 7) 
		and not(mins >= ex_dimineata and mins <= ex_dimineata + 7)
		and not(mins >= dejun and mins <= dejun + 7) 
		and not(mins >= pranz and mins <= pranz + 7)
		and not(mins >= ex_seara and mins <= ex_seara + 7)
		and not(mins >= cina and mins <= cina + 7)
		and not(mins >= somn and mins <= somn + 7)):
			get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
		elif mins >= trezire and mins <= trezire + 7:
			if complete_trezire == 0:
				complete_trezire = 1
				save_progress()
				get_tree().change_scene_to_file("res://trezire.tscn")
			else:
				get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
		elif mins >= ex_dimineata and mins <= ex_dimineata + 7:
			if complete_ex == 0:
				complete_ex = 1
				save_progress()
				get_tree().change_scene_to_file("res://exercitii_dimineata.tscn")
			else:
				get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
		elif mins >= dejun and mins <= dejun + 7:
			if complete_dejun == 0:
				complete_dejun = 1
				save_progress()
				get_tree().change_scene_to_file("res://spalat_maini.tscn")
			else:
				get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
		elif mins >= pranz and mins <= pranz + 7:
			if complete_pranz == 0:
				complete_pranz = 1
				save_progress()
				get_tree().change_scene_to_file("res://spalat_maini.tscn")
			else:
				get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
		elif mins >= ex_seara and mins <= ex_seara + 7:
			if complete_ex2 == 0:
				complete_ex2 = 1
				save_progress()
				get_tree().change_scene_to_file("res://exercitii_dimineata.tscn")
			else:
				get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
		elif mins >= cina and mins <= cina + 7:
			if complete_cina == 0:
				complete_cina = 1
				save_progress()
				get_tree().change_scene_to_file("res://spalat_maini.tscn")
			else:
				get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
		elif mins >= somn and mins <= somn + 7:
			if complete_somn == 0:
				complete_somn = 1
				save_progress()
				get_tree().change_scene_to_file("res://baie_dimineata.tscn")
			else:
				get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")

func change_type(string):
	var parti = string.split(":")
	var ore = parti[0].to_int()
	var minute = parti[1].to_int()
	var total_minute = (ore * 60) + minute
	return total_minute
