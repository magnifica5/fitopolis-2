# INLOCUIESTE parental_code.gd cu acest script pentru testul de asociere.
# Necesita patch-ul sign_in_anonymous deja testat si 02_child_pairing.sql.
# Necesita autoload ChildSession si pluginul actualizat din etapa 3.
extends Control

@onready var parental_code = $CanvasLayer3/Panel/LineEdit
@onready var errors = $CanvasLayer3/Panel/Label2

var autentificare_in_curs := false
var _associated_child_id := ""


func _ready() -> void:
	parental_code.max_length = 32
	if FileAccess.file_exists(ChildSession.SESSION_PATH):
		autentificare_in_curs = true
		errors.text = "Se restaureaza sesiunea..."
		var restored := await ChildSession.restore_and_sync()
		autentificare_in_curs = false
		if restored:
			get_tree().change_scene_to_file("res://login.tscn")
		else:
			errors.text = ChildSession.last_error


func _on_verifica() -> void:
	if autentificare_in_curs:
		return
	if not _associated_child_id.is_empty():
		await _finish_association()
		return
	var pairing_code: String = parental_code.text.strip_edges().to_upper()
	if pairing_code.length() != 32:
		errors.text = "Introdu codul nou de asociere (32 caractere)."
		return

	autentificare_in_curs = true
	errors.text = "Se verifica sesiunea..."

	if Supabase.auth.client == null:
		var auth_task = Supabase.auth.sign_in_anonymous()
		var auth_result = await auth_task.completed
		if auth_result.error != null:
			errors.text = "Autentificarea a esuat."
			push_error(str(auth_result.error.message))
			autentificare_in_curs = false
			return

	var user = Supabase.auth.client
	if user == null:
		errors.text = "Nu exista o sesiune valida."
		autentificare_in_curs = false
		return
	if not bool(user.dict.get("is_anonymous", false)):
		errors.text = "Deconecteaza mai intai contul parintelui."
		autentificare_in_curs = false
		return

	var task = Supabase.database.Rpc(
		"fitopolis_claim_pairing_code",
		{"p_pairing_code": pairing_code}
	)
	var result = await task.completed
	if result.error != null:
		errors.text = "Asocierea a esuat. Vezi eroarea din Output."
		push_error(str(result.error.message))
		autentificare_in_curs = false
		return
	if not result.data is Dictionary:
		errors.text = "Raspuns invalid de la server."
		autentificare_in_curs = false
		return

	_associated_child_id = str(result.data.get("child_id", ""))
	autentificare_in_curs = false
	await _finish_association()


func _finish_association() -> void:
	autentificare_in_curs = true
	errors.text = "Se salveaza sesiunea si se incarca profilul..."
	var saved := await ChildSession.activate_current_session(_associated_child_id)
	autentificare_in_curs = false
	if not saved:
		errors.text = ChildSession.last_error
		if ChildSession.needs_pairing:
			_associated_child_id = ""
		return
	parental_code.clear()
	get_tree().change_scene_to_file("res://alege_personaj.tscn")
