extends Control

@onready var inregistreaza = $CanvasLayer3/Panel/Button
@onready var error = $CanvasLayer3/Panel/Label
@onready var username = $CanvasLayer3/Panel/LineEdit

func _on_inregistreaza() -> void:
	if username.text == "":
		error.text = "Alege un username pentru profilul tau"
		return
	
	error.text = ""
	
	# PASUL 1: Verificăm dacă username-ul există folosind SELECT
	var is_taken = await check_unique_username(username.text)
	
	if is_taken:
		error.text = "Acest nume este deja folosit!"
		return
	
	# PASUL 2: Dacă e liber, procedăm la inserare
	var user = Supabase.auth.client
	if user == null:
		error.text = "Eroare: Sesiune expirată. Loghează-te din nou."
		return
	var parent_id = user.id
	print(typeof(parent_id))
	var new_data = {
		"username": username.text.strip_edges(),
		"avatar_number": Globals.selected_index,
		"parent_id": parent_id
	}
	
	var query = SupabaseQuery.new().from("children").insert([new_data])
	var task_insert = Supabase.database.query(query)
	var res_insert = await task_insert.completed
	
	if res_insert.error == null:
		print("Succes! Copilul a fost adăugat.")
		# Aici poți schimba scena sau închide meniul
	else:
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
