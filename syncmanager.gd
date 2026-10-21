extends Node

var is_syncing := false
var is_syncing_parent := false

func sync_data():
	if is_syncing:
		return
	is_syncing = true
	var date = await get_data_from_supabase_children()
	var data = await get_data_from_supabase_progress()
	if date and data:
		Globals.usernamed = date.username
		Globals.scored = date.scor
		#Globals.activitiesd = date.activities
		Globals.badgesd = date.get("badges", {})
		Globals.avatar_numberd = date.avatar_number
		Globals.created_atd = date.created_at
		Globals.connection_coded = date.connection_code
		Globals.trezire = date.trezire
		Globals.ex = date.ex1
		Globals.dejun = date.masa_dimineata
		Globals.pranz = date.masa_pranz
		Globals.ex2 = date.ex2
		Globals.cina = date.masa_seara
		Globals.somn = date.culcare
		
		HourActivity.complete_trezire = data.trezire
		HourActivity.complete_ex = data.ex1
		HourActivity.complete_dejun = data.masa_dimineata
		HourActivity.complete_pranz = data.masa_pranz
		HourActivity.complete_ex2 = data.ex2
		HourActivity.complete_cina = data.masa_seara
		HourActivity.complete_somn = data.somn
		HourActivity.missed = data.missed
		HourActivity.activities = data.activities
		save_local_data()
	is_syncing = false


func sync_data_parents():
	if is_syncing_parent:
		return
	is_syncing_parent = true
	var date = await get_children_based_on_parent()
	var datep = await get_children_progress_based_on_parent()
	if date != null and datep != null:
		Globals.copii.clear()
		# Salvăm datele de bază ale fiecărui copil.
		for copil in date:
			var cod = copil.connection_code
			Globals.copii[cod] = {
				"username": copil.username,
				"avatar_number": copil.avatar_number,
				"verificare": copil.verificare,
				"check_verificare": copil.check_verificare,
				"created_at": copil.created_at,
				"scor": copil.scor
			}
		# Adăugăm progresul fără să ștergem datele existente.
		for progres in datep:
			var cod = progres.connection_code
			if not Globals.copii.has(cod):
				Globals.copii[cod] = {}
			Globals.copii[cod]["missed"] = progres.missed
		save_parent_data()
	is_syncing_parent = false

	
func get_data_from_supabase_children():
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		return data
	return null
	
func get_children_based_on_parent():
	var parent = Supabase.auth.client
	if parent == null: return
	var query = SupabaseQuery.new().from("children").select().eq("parent_id", parent.id) # selecteaza toate coloanele in care avem id al acestui parinte
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null:
		return result.data
	return null

func get_children_progress_based_on_parent():
	var parent = Supabase.auth.client
	if parent == null: return
	var query = SupabaseQuery.new().from("progres_copil").select().eq("parent_id", parent.id) # selecteaza toate coloanele in care avem id al acestui parinte
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null:
		return result.data
	return null

func get_data_from_supabase_progress():
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("progres_copil").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		return data
	return null

func save_local_data():
	var data = {
		"username": Globals.usernamed,
		"score": Globals.scored,
		"badges": Globals.badgesd,
		"avatar_number": Globals.avatar_numberd,
		"created_at": Globals.created_atd,
		"connection_code": Globals.connection_coded,
		"trezire": str(HourActivity.complete_trezire),
		"ex1": str(HourActivity.complete_ex),
		"masa_dimineata": str(HourActivity.complete_dejun),
		"masa_pranz": str(HourActivity.complete_pranz),
		"ex2": str(HourActivity.complete_ex2),
		"masa_seara": str(HourActivity.complete_cina),
		"somn": str(HourActivity.complete_somn),
		"missed": str(HourActivity.missed),
		"activities": str(HourActivity.activities),
		"trezire_ora": Globals.trezire,
		"ex1_ora": Globals.ex,
		"masa_dimineata_ora": Globals.dejun,
		"masa_pranz_ora": Globals.pranz,
		"ex2_ora": Globals.ex2,
		"masa_seara_ora": Globals.cina,
		"somn_ora": Globals.somn
	}
	var file = FileAccess.open("user://user_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_local_data():
	if not FileAccess.file_exists("user://user_data.json"):
		return
	var file = FileAccess.open("user://user_data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var data = JSON.parse_string(content)
		if data:
			Globals.usernamed = data.username
			Globals.scored = data.score
			Globals.activitiesd = data.activities
			Globals.badgesd = data.get("badges", {})
			Globals.avatar_numberd = data.avatar_number
			Globals.created_atd = data.created_at
			Globals.connection_coded = data.connection_code
			Globals.trezire = data.trezire_ora
			Globals.ex = data.ex1_ora
			Globals.dejun = data.masa_dimineata_ora
			Globals.pranz = data.masa_pranz_ora
			Globals.ex2 = data.ex2_ora
			Globals.cina = data.masa_seara_ora
			Globals.somn = data.somn_ora
			
			HourActivity.complete_trezire = int(data.trezire)
			HourActivity.complete_ex = int(data.ex1)
			HourActivity.complete_dejun = int(data.masa_dimineata)
			HourActivity.complete_pranz = int(data.masa_pranz)
			HourActivity.complete_ex2 = int(data.ex2)
			HourActivity.complete_cina = int(data.masa_seara)
			HourActivity.complete_somn = int(data.somn)
			HourActivity.missed = int(data.missed)
			HourActivity.activities = int(data.activities)

func save_parent_data():
	var data = {
		"lista_copii": Globals.copii
	}
	var file = FileAccess.open("user://parent_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_parent_data():
	if not FileAccess.file_exists("user://parent_data.json"):
		return
	var file = FileAccess.open("user://parent_data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var data = JSON.parse_string(content)
		if typeof(data) == TYPE_DICTIONARY:
			var lista = data.get("lista_copii", {})
			Globals.copii.clear()
			if typeof(lista) == TYPE_DICTIONARY:
				Globals.copii = lista
