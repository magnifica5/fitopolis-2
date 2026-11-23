
extends Control

# Scena reutilizabilă pentru fiecare cartonaș.
const CARD_SCENE: PackedScene = preload("res://memory_card.tscn")

# Folderul cu imaginile pentru fața cartonașelor.
const FRONTS_PATH: String = "res://memory_cards_game/fronts/"
# Dimensiunea originală a unei imagini.
# Cartonașele tale au 256 × 256 px.
const CARD_SOURCE_SIZE: int = 256

# Distanța dintre două cartonașe alăturate.
const CARD_SPACING: int = 12

# Marginea interioară a tablei:
# distanța dintre marginea tablei și grila de cartonașe.
const BOARD_PADDING: int = 85
const CARD_SIZE_STEP: int = 16

# Reținem dacă am programat deja o redimensionare.
# Astfel, mai multe notificări apropiate nu declanșează
# inutil același calcul de mai multe ori.
var _board_resize_queued: bool = false

# Lista în care încărcăm toate imaginile disponibile.
var card_textures: Array[Texture2D] = []

# Numărul de perechi din nivelul curent.
# 3 perechi = 6 cartonașe.

# Nivelul la care se află copilul.
var current_level: int = 102

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
	# GameArea este spațiul disponibil pentru tablă.
	# Dacă dimensiunea lui se schimbă, recalculăm așezarea.
	game_area.resized.connect(_queue_board_resize)

	# Încărcăm imaginile disponibile pentru perechi.
	load_card_textures()

	# Acest timer controlează cât timp rămâne vizibilă
	# o pereche greșită înainte să întoarcem cartonașele.
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	# Stabilim numărul de perechi pentru nivelul actual.
	configure_level()

	# Stabilim numărul de coloane pentru aceste perechi.
	configure_grid_layout()

	# Fiecare pereche are nevoie de o imagine distinctă.
	if card_textures.size() < pairs_count:
		push_error("Nu există suficiente imagini pentru acest nivel!")
		return

	# Creăm cartonașele.
	# La finalul acestei funcții vom programa și redimensionarea.
	create_cards()


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
	# Acum există toate cartonașele în grilă.
	# Putem programa calcularea dimensiunii lor și a tablei.
	_queue_board_resize()


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
# Stabilește câte coloane are grila.
# Godot calculează automat rândurile din numărul de cartonașe.
func configure_grid_layout() -> void:
	# Fiecare pereche este formată din două cartonașe.
	var total_cards: int = pairs_count * 2

	# Alegem aranjamente cu rânduri complete.
	# Valorile reprezintă numărul de COLOANE.
	match total_cards:
		6:
			grid.columns = 3  # 3 coloane × 2 rânduri

		8:
			grid.columns = 4  # 4 coloane × 2 rânduri

		10:
			grid.columns = 5  # 5 coloane × 2 rânduri

		12:
			grid.columns = 4  # 4 coloane × 3 rânduri

		14:
			grid.columns = 7  # 7 coloane × 2 rânduri

		16:
			grid.columns = 4  # 4 coloane × 4 rânduri

		18:
			grid.columns = 6  # 6 coloane × 3 rânduri

		20:
			grid.columns = 5  # 5 coloane × 4 rânduri

	# Împărțim numărul cartonașelor la numărul de coloane.
	# ceili() rotunjește în sus dacă rezultatul nu este întreg.
	var rows: int = ceili(
		float(total_cards) / float(grid.columns)
	)

	print("Cartonașe: ", total_cards)
	print("Coloane: ", grid.columns)
	print("Rânduri: ", rows)


# Programează recalcularea dimensiunilor.
func _queue_board_resize() -> void:
	# Dacă există deja un apel programat, nu mai adăugăm unul.
	if _board_resize_queued:
		return

	_board_resize_queued = true

	# call_deferred() amână executarea până la procesarea
	# apelurilor amânate de Godot.
	# Nu recalculăm direct în mijlocul notificării de redimensionare.
	resize_board.call_deferred()


# Calculează dimensiunea cartonașelor, a grilei și a tablei.
func resize_board() -> void:
	# Redimensionarea programată este executată acum.
	_board_resize_queued = false

	var total_cards: int = grid.get_child_count()

	# Nu calculăm dimensiunile înainte să existe cartonașe.
	if total_cards == 0:
		return

	# Numărul de coloane este stabilit în configure_grid_layout().
	var columns: int = grid.columns

	# Calculăm numărul de rânduri necesare.
	var rows: int = ceili(
		float(total_cards) / float(columns)
	)

	# Folosim constantele declarate anterior în script.
	var spacing: float = float(CARD_SPACING)
	var padding: float = float(BOARD_PADDING)

	# PANOU:
	# Dimensiunea lui depinde doar de spațiul disponibil.
	# Nu îl mai micșorăm după dimensiunea grilei.
	#
	# La schimbarea nivelului, panoul rămâne la aceeași mărime
	# dacă GameArea nu și-a schimbat dimensiunea.
	var available_width: float = floorf(game_area.size.x * 0.95)
	var available_height: float = floorf(game_area.size.y * 0.95)

	# Calculăm câtă lățime poate avea un cartonaș.
	#
	# Scădem:
	# - marginile interioare din stânga și dreapta;
	# - spațiile dintre coloane.
	#
	# Împărțim spațiul rămas la numărul de coloane.
	var max_card_width: float = (
		available_width
		- padding * 2.0
		- spacing * float(columns - 1)
	) / float(columns)

	# Facem același calcul pentru înălțime.
	var max_card_height: float = (
		available_height
		- padding * 2.0
		- spacing * float(rows - 1)
	) / float(rows)

	# Cartonașele rămân pătrate.
	# Alegem cea mai mică dintre limitele de lățime și înălțime.
	#
	# Limităm și la dimensiunea originală de 256 px,
	# pentru a evita mărirea peste rezoluția texturilor.
	var max_card_size: float = minf(
		float(CARD_SOURCE_SIZE),
		minf(max_card_width, max_card_height)
	)

	if max_card_size < 1.0:
		return

	# Alegem cel mai mare multiplu de 16 care încape.
	#
	# Exemplu:
	# Dacă avem loc pentru maximum 230 px:
	# 230 / 16 = 14,375
	# floori(...) = 14
	# 14 * 16 = 224 px
	var card_side: int = (
		floori(max_card_size / float(CARD_SIZE_STEP))
		* CARD_SIZE_STEP
	)

	# Protecție pentru o zonă de joc extrem de mică:
	# evităm să obținem cartonașe cu dimensiunea zero.
	if card_side < 1:
		card_side = floori(max_card_size)

	var card_size := Vector2(card_side, card_side)

	# Spațierea reală trebuie să fie aceeași cu cea din calcule.
	grid.add_theme_constant_override(
		"h_separation",
		CARD_SPACING
	)

	grid.add_theme_constant_override(
		"v_separation",
		CARD_SPACING
	)

	# Aplicăm aceeași dimensiune tuturor cartonașelor.
	# Front și Back vor urma dimensiunea părintelui,
	# folosind setările pe care le-ai corectat deja.
	for card in grid.get_children():
		card.custom_minimum_size = card_size
		card.size = card_size

	# Calculăm dimensiunea grilei, inclusiv spațiile.
	var grid_width: float = (
		float(columns * card_side)
		+ float(columns - 1) * spacing
	)

	var grid_height: float = (
		float(rows * card_side)
		+ float(rows - 1) * spacing
	)

	var grid_size := Vector2(grid_width, grid_height)

	# Panoul trebuie să cuprindă grila și marginile interioare.
	#
	# Îi permitem să se micșoreze până la 80% din dimensiunea
	# maximă disponibilă, pentru a evita schimbările prea mari.
	#
	# clampf(valoare, minim, maxim) păstrează valoarea
	# între limita minimă și cea maximă.
	var new_board_size := Vector2(
		clampf(
			grid_size.x + padding * 2.0,
			available_width * 0.80,
			available_width
		),
		clampf(
			grid_size.y + padding * 2.0,
			available_height * 0.80,
			available_height
		)
	).floor()
	board.custom_minimum_size = new_board_size
	board.size = new_board_size

	# Centrăm grila în panou.
	#
	# Diferența dintre dimensiunea panoului și cea a grilei
	# reprezintă spațiul liber. Îl împărțim în două,
	# astfel încât marginile opuse să fie egale.
	#
	# floor() păstrează poziția pe coordonate întregi.
	grid.position = (
		(new_board_size - grid_size) / 2.0
	).floor()

	grid.size = grid_size

	# Fundalul acoperă întregul panou.
	board_background.position = Vector2.ZERO
	board_background.size = new_board_size

	print("Dimensiune cartonaș: ", card_side, " × ", card_side)
	print("Dimensiune panou: ", new_board_size)
