extends Control
@onready var email = $CanvasLayer3/Panel/LineEdit
@onready var password = $CanvasLayer3/Panel/LineEdit2
@onready var label = $CanvasLayer3/Panel/Label5
var result
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_registered_pressed() -> void:
	get_tree().change_scene_to_file("res://account_type.tscn")


func _on_login() -> void:
	var e = email.text.strip_edges()
	var p = password.text
	var task = Supabase.auth.sign_in(e, p)
	result = await task.completed
	if result.error == null:
		print("Logare reusita")
		asociaza_cod()
	else:
		var message = result.error.message.to_lower()
		if "invalid login credentials" in message:
			print("Email-ul sau parola sunt greșite. Te rugăm să încerci din nou.")
			label.text = "Email-ul sau parola sunt gresite. Te rugam sa incerci din nou."


func genereaza_cod():
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var res = ""
	for i in range(6):
		var chr = characters[randi() % characters.length()]
		res += chr
	return res

func asociaza_cod():
	var salvat = false
	var id_parinte = result.data.user.id
	var incercari = 0
	# OBLIGATORIU: Așteptăm un frame ca addon-ul de Supabase 
	# să apuce să salveze local token-ul utilizatorului proaspăt înregistrat
	await get_tree().create_timer(0.5).timeout
	
	while salvat == false and incercari < 5:
		incercari += 1
		var cod = genereaza_cod()
		var save = {
			"id" : id_parinte,
			"connection_code": cod
		}
		
		print("Încercarea ", incercari, " pentru ID parent: ", id_parinte)
		
		# Sintaxa corectă pentru versiunea ta de addon:
		var query = SupabaseQuery.new().from("parents").insert([save])
		var task = Supabase.database.query(query)
		var res = await task.completed
		
		if res.error == null:
			salvat = true
			print("Codul UNIC de conectare este: ", cod)
		else:
			print("Eroare de la Supabase: ", res.error.message)
			if "duplicate" in res.error.message.to_lower():
				print("Codul exista deja. Generăm altul...")
			else:
				# Dacă e eroare de RLS (de ex: "violates row-level security policy"), o afișăm și ne oprim
				break
