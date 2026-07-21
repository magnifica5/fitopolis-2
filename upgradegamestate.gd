# UpgradeButton.gd
extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameState.valoare_globala += 1
	GameState.level_updated.emit()
	get_parent().visible = false
	# Salvează valoarea nouă pe disc!
	GameState.salveaza_jocul()
