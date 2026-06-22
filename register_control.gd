extends Control
@onready var email_input = $CanvasLayer3/Panel/LineEdit
@onready var password_input = $CanvasLayer3/Panel/LineEdit2
@onready var termeni_check = $CanvasLayer3/Panel/CheckBox2
@onready var politica_check = $CanvasLayer3/Panel/CheckBox3
@onready var password_check = $CanvasLayer3/Panel/LineEdit2/Label
@onready var erori = $CanvasLayer3/Panel/Label5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Supabase.config.supabase_url = "https://etvqohlilszwtwbqobtq.supabase.co"
	Supabase.config.supabase_anon_key = "sb_publishable_Y-5_r6PoTMff-eDLJj0FMw_gLCxdGwG"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_terms_pressed() -> void:
	get_tree().change_scene_to_file("res://termeni.tscn")


func _on_policy_pressed() -> void:
	get_tree().change_scene_to_file("res://politica.tscn")


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
	var result = await task.completed
	if result.error == null:
		print("Cont de părinte creat! ID-ul lui este: ", result.data.id)
	else:
		print("Eroare la creare părinte: ", result.error.message)
	
	
		
	
