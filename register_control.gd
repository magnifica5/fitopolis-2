extends Control
@onready var email_input = $CanvasLayer3/Panel/LineEdit
@onready var password_input = $CanvasLayer3/Panel/LineEdit2
@onready var termeni_check = $CanvasLayer3/Panel/CheckBox2
@onready var politica_check = $CanvasLayer3/Panel/CheckBox3
@onready var password_check = $CanvasLayer3/Panel/LineEdit2/Label
@onready var erori = $CanvasLayer3/Panel/Label5
@onready var popup_termeni = $CanvasLayer3/Panel/Panel
@onready var popup_conditii = $CanvasLayer3/Panel/Panel2
@onready var panel_register = $CanvasLayer3/Panel
@onready var panel_check = $CanvasLayer3/Panel2
var result
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_termeni.hide()
	popup_conditii.hide()
	panel_register.show()
	panel_check.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_terms_pressed() -> void:
	popup_termeni.show()


func _on_policy_pressed() -> void:
	popup_conditii.show()


func is_valid_email(email: String):
	email = email_input.text.strip_edges()
	var pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
	var regex = RegEx.new()
	var error = regex.compile(pattern)
	if error != OK:
		print("Eroare la compilarea regex-ului")
		return false
	return regex.search(email) != null

func _on_inregistreaza() -> void:
	var email = email_input.text.strip_edges()
	var parola = password_input.text
	if !is_valid_email(email):
		erori.text = "Adresa de email invalida"
		return
	if password_check.text != "" or password_input.text == "":
		erori.text = "Parola invalida"
		return
	if not termeni_check.button_pressed or not politica_check.button_pressed:
		erori.text = "Nu puteti continua daca nu sunteti de acord cu Termenii si Politica."
		return
	erori.text = ""
	var task = Supabase.auth.sign_up(email, parola)
	result = await task.completed
	if result.error == null:
		if result.data.identities.size() == 0:
			erori.text = "Acest email este deja asociat unui cont! Incearca sa te loghezi."
			print("Utilizatorul există deja (Enumeration Protection)")
		else:
			# UTILIZATOR NOU: Totul a mers bine
			panel_register.hide()
			panel_check.show()
		
func _close_termeni() -> void:
	popup_termeni.hide()


func _close_politica() -> void:
	popup_conditii.hide()


func _back_inregistrare() -> void:
	get_tree().change_scene_to_file("res://background_login.tscn")
