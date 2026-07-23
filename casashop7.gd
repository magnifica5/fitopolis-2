extends TextureButton

@onready var label = $Sprite2D/Label

# Preîncărcăm textura o singură dată la pornirea jocului, nu la fiecare apăsare
const CALE_IMAGINE = "res://assets/nigu13.png"
var textura_item = preload(CALE_IMAGINE)

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# 1. Prevenim spam-ul dezactivând butonul
	disabled = true 
	
	Globals.code = Globals.citeste_code()
	var cost_item = int(label.text)
	
	# 2. Prima interogare: Verificăm scorul
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	
	if result.error != null:
		print("Eroare la citirea scorului: ", result.error)
		disabled = false # Reactivăm butonul în caz de eroare
		return
		
	var data = result.data
	# 3. Validăm că am primit date pentru a evita crash-ul
	if data == null or data.is_empty():
		print("Eroare: Nu s-a găsit utilizatorul cu acest cod.")
		disabled = false
		return
		
	var score = data[0].scor
	
	if score >= cost_item:
		var scor_nou = score - cost_item
		
		# 4. A doua interogare: Actualizăm scorul
		var query2 = SupabaseQuery.new().from("children").update({"scor": int(scor_nou)}).eq("connection_code", Globals.code)
		var task2 = Supabase.database.query(query2)
		var result2 = await task2.completed
		
		if result2.error == null:
			Globals.adauga_scor(scor_nou)
			print("Scor modificat cu succes!")
			
			# 5. Setăm direct textura preîncărcată (FĂRĂ conversii inutile Image -> ImageTexture)
			Itemshop.textura_salvata = textura_item
			Itemshop.cale_textura_salvata = CALE_IMAGINE
			Itemshop.scale_salvat = 0.6
			
			Itemshop.schimba_poza_mouse.emit(textura_item) 
			
			# 6. Schimbăm scena
			var tree = get_tree()
			if tree:
				tree.change_scene_to_file("res://oras2.0.tscn")
		else:
			print("Eroare la actualizarea scorului: ", result2.error)
			disabled = false
	else:
		print("Scor insuficient!")
		disabled = false # Reactivăm butonul dacă nu are bani
