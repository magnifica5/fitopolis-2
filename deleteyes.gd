extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var nod_curent = get_parent()
	var pop_up_principal: ColorRect = null
	
	# Urcăm în ierarhie nod cu nod până găsim nodul care are funcția 'confirma_stergerea'
	while nod_curent != null:
		if nod_curent.has_method("confirma_stergerea"):
			pop_up_principal = nod_curent as ColorRect
			break
		nod_curent = nod_curent.get_parent()

	if pop_up_principal:
		print("ColorRect principal găsit cu succes! Ștergem...")
		pop_up_principal.confirma_stergerea()
	else:
		print("Eroare: Nu s-a găsit ColorRect-ul principal deasupra butonului YES!")
