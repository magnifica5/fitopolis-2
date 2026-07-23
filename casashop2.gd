extends TextureButton
@onready var label = $Sprite2D/Label
func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null:
		var data = result.data
		data = data[0]
		var score = data.scor
		var text = int(label.text)
		if score >= text:
			score -= text
			print(score)
			var query2 = SupabaseQuery.new().from("children").update({"scor": int(score)}).eq("connection_code",Globals.code)
			var task2 = Supabase.database.query(query2)
			var result2 = await task2.completed
			if result2.error == null:
				Globals.adauga_scor(int(score))
				print("scor modificat")
				print("Butonul a fost apasat cu succes!")
				var cale_imagine = "res://assets/nigu232-removebg-preview.png"
				var poza_y = preload("res://assets/nigu232-removebg-preview.png")
				
				var img: Image = poza_y.get_image()
				var poza_modificata = ImageTexture.create_from_image(img)
				
				# 1. Configurațiile din Autoload
				Itemshop.textura_salvata = poza_modificata
				Itemshop.cale_textura_salvata = cale_imagine
				
				# AICI SETEZI MARIMEA DORITA (de exemplu 4.5, sau 6.0, sau 2.0)
				Itemshop.scale_salvat = 0.4 
				
				# 2. Emitem semnalul
				Itemshop.schimba_poza_mouse.emit(poza_modificata) 
				
				var tree = get_tree()
				if tree:
					tree.change_scene_to_file("res://oras2.0.tscn")
