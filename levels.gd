extends CanvasLayer

const nlevels = 14
const SECONDS_IN_A_DAY = 86400
const UNLOCK_HOUR = 17  # Ora la care se deblochează nivelul zilnic

@onready var locked_texture = preload("res://assets/lacat_pizda.png")
@onready var unlocked_texture = preload("res://assets/level.png")

# Butoanele de nivel
@onready var level_buttons = [
	$VBoxContainer/HBoxContainer/Level1Button,
	$VBoxContainer/HBoxContainer/Level2Button,
	$VBoxContainer/HBoxContainer/Level3Button,
	$VBoxContainer/HBoxContainer/Level4Button,
	$VBoxContainer/HBoxContainer/Level5Button,
	$VBoxContainer/HBoxContainer/Level6Button,
	$VBoxContainer/HBoxContainer/Level7Button,
	$VBoxContainer/HBoxContainer2/Level8Button,
	$VBoxContainer/HBoxContainer2/Level9Button,
	$VBoxContainer/HBoxContainer2/Level10Button,
	$VBoxContainer/HBoxContainer2/Level11Button,
	$VBoxContainer/HBoxContainer2/Level12Button,
	$VBoxContainer/HBoxContainer2/Level13Button,
	$VBoxContainer/HBoxContainer2/Level14Button,
]

func _ready():
	# Încarcă progresul și setează start_time dacă e prima pornire
	Unlock_levels.load_data()
	Unlock_levels.init_start_time()

	# Deblocăm nivele și actualizăm UI
	check_unlocked_levels()
	update_buttons()

	# Timer live (verifică la fiecare minut dacă trebuie să deblocheze un nivel)
	var timer = Timer.new()
	timer.wait_time = 60
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func check_unlocked_levels():
	Unlock_levels.init_start_time()
	var current_time = Time.get_unix_time_from_system()
	var current_date = Time.get_datetime_dict_from_unix_time(current_time)

	# Copie Array pentru a evita read-only error
	var unlocked = Unlock_levels.unlocked_levels.duplicate()

	# Determinăm următorul nivel care trebuie deblocat
	var max_unlocked = 0
	if not unlocked.is_empty():
		max_unlocked = int(unlocked[-1])
	var next_level = max_unlocked + 1

	# Deblocăm nivelul doar dacă e trecut de ora setată
	if current_date["hour"] >= UNLOCK_HOUR and next_level <= nlevels:
		unlocked.append(next_level)

	# Convertim toate valorile la int pentru siguranță
	for i in range(unlocked.size()):
		unlocked[i] = int(unlocked[i])

	# Siguranță: nu depășim nlevels
	if unlocked.size() > nlevels:
		unlocked.resize(nlevels)

	# Salvăm progresul și actualizăm UI
	Unlock_levels.unlocked_levels = unlocked
	Unlock_levels.save_data()
	update_buttons()
	print("Nivele deblocate:", Unlock_levels.unlocked_levels)

func update_buttons():
	for i in range(level_buttons.size()):
		var button = level_buttons[i]
		var level_number = i + 1
		var label = button.get_node("Label")

		if level_number in Unlock_levels.unlocked_levels:
			button.disabled = false
			button.texture_normal = unlocked_texture
			label.visible = true
		else:
			button.disabled = true
			label.visible = false
			button.texture_normal = locked_texture

func _on_timer_timeout() -> void:
	check_unlocked_levels()
