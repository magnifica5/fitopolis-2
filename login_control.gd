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
	get_tree().change_scene_to_file("res://register_parrent.tscn")

func _on_login() -> void:
	var e = email.text.strip_edges()
	var p = password.text
	var task = Supabase.auth.sign_in(e, p)
	result = await task.completed
	
	if result.error == null:
		print("Logare reusita")
		var session = result.user
		var session_data = {
		"access_token": session.access_token,
		"refresh_token": session.refresh_token,
		"expires_in": session.expires_in,
		"user_id": session.id,
		"email": session.email
		}
		var file = FileAccess.open("user://session.save", FileAccess.WRITE)
		file.store_string(JSON.stringify(session_data))
		file.close()
		label.text = ""
		get_tree().change_scene_to_file("res://interfata_parinte.tscn")
	else:
		var message = result.error.message.to_lower()
		if "invalid login credentials" in message:
			print("Email-ul sau parola sunt greșite. Te rugăm să încerci din nou.")
			label.text = "Email-ul sau parola sunt gresite. Te rugam sa incerci din nou."

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
		errors.text = "Email invalid. "
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
