extends Node

var is_syncing := false


func sync_data():
	if is_syncing:
		return
	is_syncing = true
	var date = await get_data_from_supabase()
	if date:
		Globals.usernamed = date.username
		Globals.scored = date.scor
		#Globals.activitiesd = date.activities
		Globals.badgesd = date.get("badges", {})
		Globals.avatar_numberd = date.avatar_number
		Globals.created_atd = date.created_at
		Globals.connection_coded = date.connection_code
		save_local_data()
	is_syncing = false

func get_data_from_supabase():
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
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
		"activities": Globals.activitiesd,
		"badges": Globals.badgesd,
		"avatar_number": Globals.avatar_numberd,
		"created_at": Globals.created_atd,
		"connection_code": Globals.connection_coded
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
