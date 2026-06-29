extends Control

@onready var email = $CanvasLayer3/Panel/LineEdit
@onready var password = $CanvasLayer3/Panel/LineEdit2
@onready var label = $CanvasLayer3/Panel/Label5
@onready var email_input = $CanvasLayer3/Panel2/LineEdit
@onready var errors = $CanvasLayer3/Panel2/Label5
@onready var panel_auth = $CanvasLayer3/Panel
@onready var panel_reset = $CanvasLayer3/Panel2
@onready var label_pas = $CanvasLayer3/Panel3/Label4
@onready var new_pass = $CanvasLayer3/Panel3/LineEdit2
@onready var panel_reset_final = $CanvasLayer3/Panel3
@onready var verifica = $CanvasLayer3/Panel3/Button
@onready var reseteaza = $CanvasLayer3/Panel3/Button2
@onready var cod_input = $CanvasLayer3/Panel3/LineEdit
@onready var error = $CanvasLayer3/Panel3/Label5
@onready var final = $CanvasLayer3/Panel4

var result

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel_auth.show()
	panel_reset.hide()
	panel_reset_final.hide()
	final.hide()
	cod_input.editable = true

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
		label.text = ""
		var user = result.data.user
		print(user)
		
		var query := SupabaseQuery.new()
		query.from("parents").select(["*"]).eq("id", user.id)
		
		var task2 = Supabase.database.query(query)
		var response = await task2.completed
		
		if response.error:
			print(response.error)
			return
			
		if response.data.size() > 0:
			print("Utilizatorul există.")
		else:
			print("Utilizatorul nu există.")
			asociaza_cod()
		get_tree().change_scene_to_file("res://interfata_parinte.tscn")
	else:
		var message = result.error.message.to_lower()
		if "invalid login credentials" in message:
			print("Email-ul sau parola sunt greșite. Te rugăm să încerci din nou.")
			label.text = "Email-ul sau parola sunt gresite. Te rugam sa incerci din nou."

func genereaza_cod() -> String:
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var res = ""
	for i in range(6):
		var chr = characters[randi() % characters.length()]
		res += chr
	return res

func asociaza_cod() -> void:
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
				break

func _on_reseteaza() -> void:
	panel_auth.hide()
	panel_reset.show()

func _on_continua() -> void:
	var e = email_input.text.strip_edges()
	var task = Supabase.auth.reset_password_for_email(e)
	var res = await task.completed
	
	if res.error == null:
		errors.text = "Email-ul de resetare a fost trimis! Verifică-ți inbox-ul."
		print("Succes: Email de resetare trimis către ", e)
		panel_reset.hide()
		label_pas.hide()
		new_pass.hide()
		verifica.show()
		reseteaza.hide()
		panel_reset_final.show()
	else:
		errors.text = "Eroare: " + res.error.message
		print("Eroare la resetare: ", res.error.message)

func _on_verifica_cod() -> void:
	var cod = cod_input.text.strip_edges()
	var e = email_input.text.strip_edges()
	var task = Supabase.auth.verify_otp_email(e, cod, "recovery")
	var res = await task.completed
	
	if res.error == null:
		print("Cod corect! Acum poți seta noua parolă.")
		new_pass.show()
		label_pas.show()
		verifica.hide()
		reseteaza.show()
		cod_input.editable = false
		error.text = ""
	else:
		error.text = "Cod invalid sau expirat."

func _on_reset_password() -> void:
	var npass = new_pass.text
	if error.text == "":
		var task = Supabase.auth.update("", npass)
		var res = await task.completed
		if res.error == null:
			panel_reset_final.hide()
			final.show()

func _on_catre_login() -> void:
	final.hide()
	panel_auth.show()
