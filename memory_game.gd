
extends Control

# Scena reutilizabilă pentru fiecare cartonaș.
const CARD_SCENE: PackedScene = preload("res://memory_card.tscn")

# Folderul cu imaginile pentru fața cartonașelor.
const FRONTS_PATH: String = "res://memory_cards_game/fronts/"

# Lista în care încărcăm toate imaginile disponibile.
var card_textures: Array[Texture2D] = []

# Numărul de perechi din nivelul curent.
# 3 perechi = 6 cartonașe.

# Nivelul la care se află copilul.
var current_level: int = 300

# Numărul maxim de niveluri disponibile.
const MAX_LEVEL: int = 300

# Numărul de perechi din nivelul actual.
var pairs_count: int = 3


# Referințe către nodurile scenei.
@onready var grid: GridContainer = $HBoxContainer/GameArea/CenterContainer/Board/GridContainer
@onready var game_area: Control = $HBoxContainer/GameArea
@onready var board: Control = $HBoxContainer/GameArea/CenterContainer/Board
@onready var board_background: Control = $HBoxContainer/GameArea/CenterContainer/Board/BoardBackground
@onready var timer: Timer = $Timer

# Cele două cartonașe selectate.
var first_card: Control = null
var second_card: Control = null

# Numărul perechilor găsite.
var matched_pairs: int = 0

# Numărul greșelilor efectuate.
var mistakes: int = 0

# Indică dacă verificăm deja o pereche.
var is_checking: bool = false

# Devine true atunci când nivelul este terminat.
var game_finished: bool = false


# Stabilește numărul de perechi în funcție de nivel.
func configure_level() -> void:
	# Ne asigurăm că nivelul este între 1 și 300.
	current_level = clampi(current_level, 1, MAX_LEVEL)

	# Stabilim numărul de perechi.
	if current_level <= 10:
		pairs_count = 3
	elif current_level <= 30:
		pairs_count = 4
	elif current_level <= 60:
		pairs_count = 5
	elif current_level <= 100:
		pairs_count = 6
	elif current_level <= 150:
		pairs_count = 7
	elif current_level <= 200:
		pairs_count = 8
	elif current_level <= 250:
		pairs_count = 9
	else:
		pairs_count = 10

	print("Nivel: ", current_level)
	print("Perechi: ", pairs_count)


# Se execută automat când începe jocul.


func _ready() -> void:
	# Încărcăm imaginile disponibile.
	load_card_textures()

	# Configurăm timerul pentru perechile greșite.
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	# Configurăm dificultatea nivelului actual.
	configure_level()

	# Stabilim numărul de coloane în funcție de nivel.
	configure_grid_layout()

	# Verificăm dacă avem suficiente imagini.
	if card_textures.size() < pairs_count:
		push_error("Nu există suficiente imagini pentru acest nivel!")
		return

	# Generăm cartonașele.
	create_cards()
	await get_tree().process_frame
	resize_board()




# Încarcă automat imaginile, inclusiv pe Android.
func load_card_textures() -> void:
	# Golim lista înainte de încărcare.
	card_textures.clear()

	# Obținem lista resurselor din folder.
	# Spre deosebire de DirAccess, această metodă
	# ține cont de resursele importate de Godot.
	var files: PackedStringArray = ResourceLoader.list_directory(FRONTS_PATH)

	# Sortăm fișierele pentru o ordine constantă.
	files.sort()

	for file_name in files:
		# Verificăm dacă fișierul este o imagine.
		var extension = file_name.get_extension().to_lower()

		if extension in ["png", "jpg", "jpeg", "webp"]:
			# Construim calea completă.
			var path: String = FRONTS_PATH + file_name

			# Încărcăm textura folosind ResourceLoader.
			var texture: Texture2D = ResourceLoader.load(path) as Texture2D

			if texture != null:
				card_textures.append(texture)
			else:
				push_warning("Nu s-a încărcat imaginea: " + path)

	print("Imagini încărcate: ", card_textures.size())



# Generează cartonașele pentru nivelul curent.
func create_cards() -> void:
	# Resetăm progresul nivelului.
	matched_pairs = 0
	mistakes = 0
	is_checking = false
	game_finished = false
	first_card = null
	second_card = null

	# Eliminăm eventualele cartonașe existente.
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()

	# Construim lista ID-urilor tuturor imaginilor.
	var available_ids: Array[int] = []

	for i in range(card_textures.size()):
		available_ids.append(i)

	# Amestecăm lista pentru a alege imagini aleatorii.
	available_ids.shuffle()

	# Selectăm doar imaginile necesare nivelului.
	# De exemplu: 3 imagini dacă pairs_count = 3.
	var selected_ids: Array[int] = available_ids.slice(0, pairs_count)

	# Lista cartonașelor care vor fi afișate.
	var card_ids: Array[int] = []

	# Adăugăm fiecare imagine de două ori.
	# Astfel, fiecare cartonaș are o pereche.
	for id in selected_ids:
		card_ids.append(id)
		card_ids.append(id)

	# Amestecăm pozițiile cartonașelor.
	card_ids.shuffle()

	# Generăm câte un cartonaș pentru fiecare ID.
	for id in card_ids:
		# Instanțiem scena cartonașului.
		var card = CARD_SCENE.instantiate()

		# Asociem imaginea și ID-ul perechii.
		card.setup(id, card_textures[id])

		# Adăugăm cartonașul în grilă.
		grid.add_child(card)

		# Conectăm semnalul emis la întoarcerea cartonașului.
		card.card_flipped.connect(_on_card_flipped)

	print("Cartonașe generate: ", card_ids.size())
	print("Perechi de găsit: ", pairs_count)


# Apelată când copilul întoarce un cartonaș.
func _on_card_flipped(card: Control) -> void:
	# Nu acceptăm selecții dacă nivelul s-a terminat
	# sau dacă o pereche este deja în verificare.
	if game_finished or is_checking:
		return

	# Memorăm primul cartonaș selectat.
	if first_card == null:
		first_card = card
		return

	# Memorăm al doilea cartonaș.
	second_card = card

	# Începem verificarea perechii.
	is_checking = true

	# Blocăm temporar toate cartonașele.
	lock_all_cards(true)

	# Comparăm ID-urile celor două imagini.
	if first_card.card_id == second_card.card_id:
		# Pereche corectă.
		first_card.mark_matched()
		second_card.mark_matched()

		# Creștem numărul perechilor găsite.
		matched_pairs += 1

		print("Pereche găsită! ", matched_pairs, "/", pairs_count)

		# Resetăm cartonașele selectate.
		reset_selection()

		# Verificăm dacă toate perechile au fost găsite.
		if matched_pairs == pairs_count:
			level_completed()
		else:
			# Dacă nivelul continuă, deblocăm cartonașele.
			lock_all_cards(false)

	else:
		# Pereche greșită.
		mistakes += 1

		print("Pereche greșită! Greșeli: ", mistakes)

		# Lăsăm ambele imagini vizibile o secundă.
		# Celelalte cartonașe rămân blocate în acest timp.
		timer.start(1.0)


# Este apelată după expirarea timerului.
func _on_timer_timeout() -> void:
	# Întoarcem cele două cartonașe greșite.
	if first_card != null:
		first_card.show_back()

	if second_card != null:
		second_card.show_back()

	# Resetăm selecția.
	reset_selection()

	# Permitem din nou apăsarea cartonașelor.
	if not game_finished:
		lock_all_cards(false)


# Resetează cartonașele selectate.
func reset_selection() -> void:
	first_card = null
	second_card = null
	is_checking = false


# Blochează sau deblochează cartonașele.
func lock_all_cards(lock: bool) -> void:
	for card in grid.get_children():
		# Nu modificăm cartonașele deja asociate.
		if not card.is_matched:
			card.is_locked = lock


# Apelată când toate perechile au fost găsite.
func level_completed() -> void:
	# Marcăm nivelul ca terminat.
	game_finished = true

	# Blocăm toate cartonașele.
	lock_all_cards(true)

	print("Felicitări! Nivel completat!")
	print("Greșeli efectuate: ", mistakes)


# Stabilește numărul de coloane și rânduri
# în funcție de numărul de perechi.
func configure_grid_layout() -> void:
	var total_cards: int = pairs_count * 2

	# Alegem numărul de coloane.
	if total_cards <= 6:
		grid.columns = 3
	elif total_cards <= 10:
		grid.columns = 5 if total_cards == 10 else 4
	elif total_cards <= 16:
		grid.columns = 4
	else:
		grid.columns = 5

	# Calculăm câte rânduri sunt necesare.
	var rows: int = ceili(float(total_cards) / grid.columns)

	print("Cartonașe: ", total_cards)
	print("Coloane: ", grid.columns)
	print("Rânduri: ", rows)


# Redimensionează tabla și cartonașele în funcție
# de numărul de perechi și de spațiul disponibil.

func resize_board() -> void:
	# Numărul total de cartonașe.
	var total_cards: int = pairs_count * 2

	# Numărul de coloane și rânduri.
	var columns: int = grid.columns
	var rows: int = ceili(float(total_cards) / float(columns))

	# Spațierea dintre cartonașe.
	var spacing: float = 12.0

	# Spațiul dintre marginea tablei și cartonașe.
	var padding: float = 35.0

	# Dimensiunea disponibilă în GameArea.
	var available_width: float = game_area.size.x * 0.95
	var available_height: float = game_area.size.y * 0.95

	# Calculăm lățimea maximă a cartonașului.
	var max_card_width: float = (
		available_width - padding * 2.0
		- spacing * float(columns - 1)
	) / float(columns)

	# Calculăm înălțimea maximă.
	var max_card_height: float = (
		available_height - padding * 2.0
		- spacing * float(rows - 1)
	) / float(rows)

	# Păstrăm proporția de 3:4.
	var card_width: float = min(
		max_card_width,
		max_card_height * 0.75
	)

	if card_width <= 0.0:
		return

	var card_height: float = card_width / 0.75

	# Configurăm spațiul dintre cartonașe.
	grid.add_theme_constant_override("h_separation", int(spacing))
	grid.add_theme_constant_override("v_separation", int(spacing))

	# Aplicăm dimensiunea calculată fiecărui cartonaș.
	for card in grid.get_children():
		card.custom_minimum_size = Vector2(card_width, card_height)

	# Calculăm dimensiunea reală a grilei.
	var grid_width: float = (
		float(columns) * card_width
		+ float(columns - 1) * spacing
	)

	var grid_height: float = (
		float(rows) * card_height
		+ float(rows - 1) * spacing
	)

	# Dimensiunea tablei include și marginile interioare.
	var new_board_size := Vector2(
		grid_width + padding * 2.0,
		grid_height + padding * 2.0
	)

	# Actualizăm dimensiunea minimă a tablei.
	board.custom_minimum_size = new_board_size
	board.size = new_board_size

	# Poziționăm grila în interiorul tablei.
	grid.position = Vector2(padding, padding)
	grid.size = Vector2(grid_width, grid_height)

	# Fundalul acoperă întreaga tablă.
	board_background.position = Vector2.ZERO
	board_background.size = new_board_size

	print("Dimensiune cartonaș: ", card_width, " x ", card_height)
	print("Dimensiune tablă: ", new_board_size)
