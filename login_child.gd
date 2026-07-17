extends Control

@onready var inregistreaza = $CanvasLayer3/Panel/Button
@onready var error = $CanvasLayer3/Panel/Label
@onready var username = $CanvasLayer3/Panel/LineEdit



func genereaza_cod() -> String:
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var res = ""
	for i in range(6):
		var chr = characters[randi() % characters.length()]
		res += chr
	return res

#func asociaza_cod() -> void:
	#var salvat = false
	#var user = Supabase.auth.client
	#var id_parinte = user.id
	#await get_tree().create_timer(0.5).timeout
	#while salvat == false:
		#var cod = genereaza_cod()
		#var save = {
			#"connection_code": cod
		#}
		#var query = SupabaseQuery.new().from("children").insert([save])
		#var task = Supabase.database.query(query)
		#var res = await task.completed
		#
		#if res.error == null:
			#salvat = true
			#print("Codul UNIC de conectare este: ", cod)
		#else:
			#print("Eroare de la Supabase: ", res.error.message)
			#if "duplicate" in res.error.message.to_lower():
				#print("Codul exista deja. Generăm altul...")
			#else:
				#break
func _on_inregistreaza() -> void:
	var salvat = false
	if username.text == "":
		error.text = "Alege un username pentru profilul tau"
		return
	var nume_introdus = username.text.strip_edges()
	if " " in nume_introdus:
		error.text = "Username-ul nu poate contine spatii!"
		return
	if len(nume_introdus) > 12:
		error.text = "Username-ul trebuie sa aiba maxim 12 caractere."
		return
	var is_taken = await check_unique_username(username.text)
	if is_taken:
		error.text = "Acest username este deja folosit!"
		return
	var user = Supabase.auth.client
	if user == null:
		error.text = "Eroare: Sesiune expirata. Logheaza-te din nou."
		return
	if Globals.selected_index == -1:
		error.text = "Alege o poza de profil."
		return
	error.text = ""
	var parent_id = user.id
	print(typeof(parent_id))
	while salvat == false:
		var new_data = {
			"username": username.text.strip_edges(),
			"avatar_number": Globals.selected_index,
			"parent_id": parent_id,
			"connection_code": genereaza_cod()
		}
		var query = SupabaseQuery.new().from("children").insert([new_data])
		var task_insert = Supabase.database.query(query)
		var res_insert = await task_insert.completed
		
		if res_insert.error == null:
			print("Succes! Copilul a fost adăugat.")
			salvat = true
			var query1 = SupabaseQuery.new().from("progres_copil").insert([{"connection_code": new_data.connection_code}])
			var task1 = Supabase.database.query(query1)
			var result1 = await task1.completed
			if result1.error == null:
				Globals.adauga_username(username.text.strip_edges())
				get_tree().change_scene_to_file("res://interfata_parinte.tscn")
			else:
				print(result1.error.message)
			# Aici poți schimba scena sau închide meniul
		else:
			if "duplicate" in res_insert.error.message.to_lower():
				print("Codul exista deja. Generăm altul...")
			error.text = "Eroare la salvare: " + res_insert.error.message

# Funcția de verificare stabilă
func check_unique_username(u_name: String) -> bool:
	var nume_curat = u_name.strip_edges()
	
	# Construim interogarea SELECT
	var query = SupabaseQuery.new().from("children").select(["username"]).eq("username", nume_curat)
	
	var task = Supabase.database.query(query)
	
	# Verificăm dacă task-ul a fost creat corect (evităm eroarea 31)
	if typeof(task) == TYPE_INT:
		print("Eroare tehnică la baza de date (Cod: ", task, ")")
		return true
		
	var response = await task.completed
	
	if response.error:
		print("Eroare la verificare: ", response.error.message)
		return true # Considerăm luat pentru siguranță în caz de eroare
	
	# Dacă response.data are elemente, înseamnă că numele există deja
	return response.data.size() > 0
