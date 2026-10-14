extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

# Verificăm în fiecare cadru (frame) starea lui edit_mode din Autoload
func _process(_delta: float) -> void:
	visible = Itemshop.edit_mode

func _on_pressed() -> void:
	# Verificăm dacă există clădiri salvate
	if Itemshop.cladiri.is_empty():
		print("Nu există nicio clădire de reparat.")
		return

	var numar_reparate := 0

	# Parcurgem toate clădirile din listă
	for date in Itemshop.cladiri:
		# Verificăm dacă clădirea este distrusă în prezent
		if date.get("distrusa", false) == true:
			date["distrusa"] = false # O setăm la false (reparată)
			numar_reparate += 1

	if numar_reparate > 0:
		# Salvăm modificările în fișierul JSON criptat
		Itemshop.salveaza_jocul()
		print("S-au reparat cu succes ", numar_reparate, " clădiri!")

		# Repornim scena curentă pentru a reîncărca aspectul normal al caselor
		get_tree().reload_current_scene()
	else:
		print("Toate clădirile sunt deja reparate! Nicio modificare necesară.")
