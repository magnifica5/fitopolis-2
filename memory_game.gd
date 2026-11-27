
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

# Durata totală a nivelului, în secunde.
# Nu este timpul rămas; acesta va fi citit ulterior din GameTimer.
var time_limit: int = 75

# Limita de greșeli a nivelului.
# mistakes, declarată deja în script, numără greșelile efectuate.
var max_mistakes: int = 3

# Fiecare dicționar descrie un interval de niveluri:
# first / last = primul și ultimul nivel, inclusiv;
# pairs = numărul de perechi;
# mistakes = limita de greșeli;
# time_start / time_end = timpul la începutul și la finalul intervalului.
const LEVEL_RULES: Array[Dictionary] = [
	{"first": 1, "last": 10, "pairs": 3, "mistakes": 3, "time_start": 75, "time_end": 55},
	{"first": 11, "last": 30, "pairs": 4, "mistakes": 3, "time_start": 90, "time_end": 65},
	{"first": 31, "last": 60, "pairs": 5, "mistakes": 4, "time_start": 110, "time_end": 80},
	{"first": 61, "last": 100, "pairs": 6, "mistakes": 4, "time_start": 130, "time_end": 95},
	{"first": 101, "last": 150, "pairs": 7, "mistakes": 10, "time_start": 150, "time_end": 110},
	{"first": 151, "last": 200, "pairs": 8, "mistakes": 5, "time_start": 170, "time_end": 125},
	{"first": 201, "last": 250, "pairs": 9, "mistakes": 6, "time_start": 190, "time_end": 140},
	{"first": 251, "last": 300, "pairs": 10, "mistakes": 6, "time_start": 210, "time_end": 155}
]


# Referințe către nodurile scenei.
@onready var grid: GridContainer = $HBoxContainer/GameArea/CenterContainer/Board/GridContainer
@onready var game_area: Control = $HBoxContainer/GameArea
@onready var board: Control = $HBoxContainer/GameArea/CenterContainer/Board
@onready var board_background: Control = $HBoxContainer/GameArea/CenterContainer/Board/BoardBackground
@onready var timer: Timer = $Timer
# Timerul pentru durata întregului nivel.
@onready var game_timer: Timer = $GameTimer

# Valorile din barele existente în scena ta.
@onready var level_value: Label = $HBoxContainer/LeftPannel/VBoxContainer/LevelBar/TextureRect/LevelValue
@onready var mode_value: Label = $HBoxContainer/LeftPannel/VBoxContainer/ModeBar/TextureRect/ModeValue
@onready var time_value: Label = $HBoxContainer/LeftPannel/VBoxContainer/TimeBar/TextureRect/TimeValue
@onready var mistake_value: Label = $HBoxContainer/LeftPannel/VBoxContainer/MistakeBar/TextureRect/MistakeValue

# Referințe către elementele panoului de rezultat.
# Le vom crea o singură dată, în _ready().
var result_overlay: ColorRect
var result_title: Label
var result_message: Label
var result_stats: Label
var result_next_button: Button
var result_retry_button: Button

# Reținem ultima secundă afișată.
# Astfel, nu rescriem același text în fiecare cadru.
var _last_displayed_second: int = -1

# Reținem dacă runda s-a terminat prin victorie.
# Vom folosi această informație și la panoul de rezultat.
var level_won: bool = false

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
	# Încadrăm nivelul în limitele jocului: 1–300.
	current_level = clampi(current_level, 1, MAX_LEVEL)

	# Căutăm intervalul din care face parte nivelul.
	for rule in LEVEL_RULES:
		var first_level: int = int(rule["first"])
		var last_level: int = int(rule["last"])

		# Dacă nivelul nu aparține acestui interval,
		# trecem la următoarea regulă.
		if current_level < first_level or current_level > last_level:
			continue

		# Perechile și limita de greșeli sunt fixe
		# în interiorul intervalului.
		pairs_count = int(rule["pairs"])
		max_mistakes = int(rule["mistakes"])

		# Calculăm poziția nivelului în interval:
		# 0.0 la primul nivel și 1.0 la ultimul.
		#
		# maxi(..., 1) evită împărțirea la zero dacă vei defini
		# vreodată un interval format dintr-un singur nivel.
		var interval_length: int = maxi(last_level - first_level, 1)
		var progress: float = (
			float(current_level - first_level) / float(interval_length)
		)

		var start_time: float = float(rule["time_start"])
		var end_time: float = float(rule["time_end"])

		# Timpul scade treptat de la start_time la end_time.
		# roundi() rotunjește rezultatul la secunde întregi.
		time_limit = roundi(lerpf(start_time, end_time, progress))

		# Verificăm valorile în panoul Output al editorului.
		print("Nivel: ", current_level)
		print("Perechi: ", pairs_count)
		print("Cartonașe: ", pairs_count * 2)
		print("Timp disponibil: ", time_limit, " secunde")
		print("Limită de greșeli: ", max_mistakes)

		# Am găsit regula potrivită; încheiem funcția.
		return

	# Ajungem aici numai dacă tabelul este modificat
	# și rămâne un interval neacoperit.
	push_error("Lipsește configurația pentru nivelul %d." % current_level)

func _ready() -> void:
	create_result_panel()
	game_area.resized.connect(_queue_board_resize)

	# Oprim eventualele porniri automate din Inspector.
	timer.stop()
	game_timer.stop()

	# Fiecare timer se oprește după expirare.
	timer.one_shot = true
	game_timer.one_shot = true

	# Conectăm fiecare semnal o singură dată.
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

	if not game_timer.timeout.is_connected(_on_game_timer_timeout):
		game_timer.timeout.connect(_on_game_timer_timeout)

	# Imaginile se încarcă o singură dată, la deschiderea scenei.
	load_card_textures()

	# Configurăm și pornim nivelul.
	start_level(current_level)


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


func _on_card_flipped(card: Control) -> void:
	# Ignorăm selecțiile după final sau în timpul verificării.
	if game_finished or is_checking or card.is_matched:
		return

	# O apăsare chiar la expirarea timpului
	# nu trebuie să poată aduce victoria.
	if game_timer.time_left <= 0.0:
		card.show_back()
		_on_game_timer_timeout()
		return

	# Un cartonaș nu poate forma o pereche cu el însuși.
	if card == first_card:
		return

	# Prima selecție: memorăm cartonașul și așteptăm al doilea.
	if first_card == null:
		first_card = card
		return

	# A doua selecție: verificăm perechea.
	second_card = card
	is_checking = true
	lock_all_cards(true)

	if first_card.card_id == second_card.card_id:
		# Pereche corectă.
		first_card.mark_matched()
		second_card.mark_matched()

		matched_pairs += 1
		reset_selection()

		if matched_pairs == pairs_count:
			level_completed()
		else:
			lock_all_cards(false)

	else:
		# Două imagini diferite înseamnă o singură greșeală.
		mistakes += 1
		update_mistakes_label()

		# La zero greșeli rămase, runda se încheie.
		if mistakes >= max_mistakes:
			finish_level(false, "Ai ajuns la limita de greșeli.")
			return

		# Lăsăm imaginile vizibile o secundă.
		# Cronometrul nivelului continuă în acest timp.
		timer.start(1.0)

func _on_timer_timeout() -> void:
	# Un semnal întârziat nu trebuie să deblocheze
	# cartonașele după terminarea rundei.
	if game_finished or not is_checking:
		return

	# Verificăm și timpul nivelului înainte de deblocare.
	if game_timer.time_left <= 0.0:
		_on_game_timer_timeout()
		return

	# Întoarcem perechea greșită cu spatele.
	if is_instance_valid(first_card):
		first_card.show_back()

	if is_instance_valid(second_card):
		second_card.show_back()

	reset_selection()
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
	# Folosim aceeași funcție de finalizare,
	# dar precizăm că rezultatul este o victorie.
	finish_level(true, "Ai găsit toate perechile!")


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

func start_level(level: int) -> void:
	result_overlay.hide()
	# Anulăm temporizările rundei anterioare.
	timer.stop()
	game_timer.stop()

	timer.paused = false
	game_timer.paused = false

	game_finished = true
	level_won = false
	reset_selection()

	# Folosim configurarea realizată în etapa 1.
	current_level = level
	configure_level()
	configure_grid_layout()

	# Fiecare pereche trebuie să aibă propria imagine.
	if card_textures.size() < pairs_count:
		lock_all_cards(true)
		push_error("Nu există suficiente imagini pentru acest nivel.")
		return

	# Funcția ta existentă resetează contoarele și creează
	# cartonașele cu spatele în sus.
	# Tot ea setează game_finished înapoi la false.
	create_cards()

	# Afișăm doar valorile.
	# Denumirile sunt deja desenate pe imaginile barelor.
	level_value.text = str(current_level)

	# Mixt = timpul și limita de greșeli sunt active simultan.
	mode_value.text = "Mixt"

	update_mistakes_label()

	# Pornim direct timpul de joc, fără memorare inițială.
	_last_displayed_second = -1
	game_timer.start(float(time_limit))
	update_time_label()


func _process(_delta: float) -> void:
	# După terminarea rundei, afișajul rămâne nemodificat.
	if game_finished:
		return

	update_time_label()


func update_time_label() -> void:
	# Rotunjim în sus:
	# de exemplu, 74,8 secunde se afișează ca 01:15.
	var seconds_left: int = ceili(game_timer.time_left)

	# Actualizăm textul numai când se schimbă secunda afișată.
	if seconds_left == _last_displayed_second:
		return

	_last_displayed_second = seconds_left

	# Transformăm secundele totale în minute și secunde.
	var minutes: int = int(seconds_left / 60.0)
	var seconds: int = seconds_left % 60

	# %02d afișează două cifre:
	# 2 minute și 9 secunde devin 02:09.
	time_value.text = "%02d:%02d" % [minutes, seconds]


func update_mistakes_label() -> void:
	# Afișăm greșelile RĂMASE.
	# Exemplu: limita 5, greșeli efectuate 2 -> afișăm 3.
	var remaining: int = maxi(max_mistakes - mistakes, 0)

	mistake_value.text = str(remaining)


func _on_game_timer_timeout() -> void:
	# Se execută când timpul nivelului ajunge la zero.
	finish_level(false, "Timpul s-a terminat.")


func finish_level(won: bool, message: String) -> void:
	# Prevenim finalizarea repetată a aceleiași runde.
	if game_finished:
		return

	# Actualizăm afișajul ÎNAINTE să oprim timerul.
	# După stop(), time_left devine zero.
	# La victorie vrem să păstrăm afișat timpul rămas.
	update_time_label()

	game_finished = true
	level_won = won

	# Oprim atât cronometrul, cât și întoarcerea perechii greșite.
	timer.stop()
	game_timer.stop()

	reset_selection()
	lock_all_cards(true)

	# În etapa următoare vom afișa panoul de rezultat aici.
	print(message)
	show_result_panel(won, message)

func create_result_panel() -> void:
	# Stratul 10 afișează panoul deasupra jocului.
	var layer := CanvasLayer.new()
	layer.name = "ResultLayer"
	layer.layer = 10
	add_child(layer)

	# Fundalul întunecat acoperă ecranul.
	# MOUSE_FILTER_STOP împiedică apăsările pe interfața din spate.
	result_overlay = ColorRect.new()
	result_overlay.color = Color(0, 0, 0, 0.55)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	# Panoul este ascuns cât timp se joacă nivelul.
	result_overlay.hide()
	layer.add_child(result_overlay)
	result_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Acest container ține panoul în centrul ecranului.
	var center := CenterContainer.new()
	result_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 0)
	center.add_child(panel)

	# Folosim același font ca pe bara nivelului.
	var popup_theme := Theme.new()
	popup_theme.default_font = level_value.get_theme_font("font")
	popup_theme.default_font_size = 32

	popup_theme.set_color(
		"font_color", "Label", Color("#214b25")
	)

	for property in [
		"font_color",
		"font_hover_color",
		"font_pressed_color",
		"font_focus_color"
	]:
		popup_theme.set_color(
			property, "Button", Color("#214b25")
		)

	panel.theme = popup_theme

	# Aspectul panoului: crem, cu margine verde.
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#fff5dc")
	panel_style.border_color = Color("#4c8d15")
	panel_style.set_border_width_all(5)
	panel_style.set_corner_radius_all(24)
	panel_style.set_content_margin_all(32)

	panel.add_theme_stylebox_override("panel", panel_style)

	# Culorile butoanelor în cele trei stări.
	var button_colors := {
		"normal": Color("#82ce24"),
		"hover": Color("#9ae144"),
		"pressed": Color("#6db91a")
	}

	for state in button_colors:
		var style := StyleBoxFlat.new()
		style.bg_color = button_colors[state]
		style.set_corner_radius_all(14)
		style.set_content_margin_all(12)

		popup_theme.set_stylebox(state, "Button", style)

	# Așezăm textele și butoanele unul sub altul.
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)

	result_title = Label.new()
	result_message = Label.new()
	result_stats = Label.new()

	for label in [
		result_title,
		result_message,
		result_stats
	]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(label)

	result_title.add_theme_font_size_override("font_size", 48)
	result_stats.add_theme_font_size_override("font_size", 28)

	# Creăm cele două butoane.
	result_next_button = Button.new()
	result_next_button.text = "Nivelul următor"

	result_retry_button = Button.new()

	for button in [
		result_next_button,
		result_retry_button
	]:
		button.custom_minimum_size = Vector2(0, 72)
		content.add_child(button)

	# Conectăm semnalele o singură dată.
	result_next_button.pressed.connect(_on_result_next_pressed)
	result_retry_button.pressed.connect(_on_result_retry_pressed)



func show_result_panel(won: bool, message: String) -> void:
	# Alegem titlul în funcție de rezultat.
	if won:
		if current_level == MAX_LEVEL:
			result_title.text = (
				"Ai încheiat nivelul %d!" % MAX_LEVEL
			)
		else:
			result_title.text = "Bravo!"
	else:
		result_title.text = "Mai încearcă!"

	# Mesajul vine din finish_level():
	# timp expirat, limită de greșeli sau toate perechile găsite.
	result_message.text = message

	# Afișăm rezultatele rundei.
	# Folosim textul deja păstrat pe bara timpului,
	# deoarece GameTimer este acum oprit.
	result_stats.text = (
		"Nivelul %d  •  Perechi: %d/%d\n"
		+ "Greșeli: %d/%d  •  Timp rămas: %s"
	) % [
		current_level,
		matched_pairs,
		pairs_count,
		mistakes,
		max_mistakes,
		time_value.text
	]

	# Următorul nivel este disponibil numai după victorie
	# și numai dacă nu am terminat deja nivelul 300.
	result_next_button.visible = (
		won and current_level < MAX_LEVEL
	)

	# Același buton poate relua atât un nivel pierdut,
	# cât și unul câștigat.
	result_retry_button.text = (
		"Joacă din nou" if won else "Reîncearcă"
	)

	result_overlay.show()

	# Alegem butonul selectat pentru utilizarea cu tastatura.
	var first_button: Button = result_retry_button

	if result_next_button.visible:
		first_button = result_next_button

	# Cu Tab, selecția rămâne pe butoanele panoului.
	result_retry_button.focus_next = (
		result_retry_button.get_path_to(first_button)
	)
	result_retry_button.focus_previous = (
		result_retry_button.focus_next
	)

	result_next_button.focus_next = (
		result_next_button.get_path_to(result_retry_button)
	)
	result_next_button.focus_previous = (
		result_next_button.focus_next
	)

	first_button.grab_focus()


func _on_result_retry_pressed() -> void:
	# Acceptăm acțiunea numai după terminarea rundei.
	if not game_finished:
		return

	# Reluăm același nivel.
	# start_level() resetează timpul, greșelile și perechile.
	# create_cards() amestecă din nou cartonașele.
	start_level(current_level)


func _on_result_next_pressed() -> void:
	# Putem avansa numai după o victorie.
	# Verificarea împiedică și avansarea repetată
	# dacă butonul este apăsat foarte rapid.
	if not game_finished or not level_won:
		return

	# Nu există nivelul 301.
	if current_level >= MAX_LEVEL:
		return

	start_level(current_level + 1)
