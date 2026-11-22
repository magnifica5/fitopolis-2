
extends Control

# Scena reutilizabilă a unui cartonaș.
const CARD_SCENE: PackedScene = preload("res://memory_card.tscn")
# Imaginile disponibile pentru perechi.
var card_textures: Array[Texture2D] = [
	preload("res://memory_cards_game/Apricot pair memory card-7.png"),
	preload("res://memory_cards_game/Blue Watering Can Memory Card-37.png"),
	preload("res://memory_cards_game/Brown Acorn and Oak Leaf-17.png"),
	preload("res://memory_cards_game/Badminton Shuttlecock Memory Card-2.png"),
	preload("res://memory_cards_game/Bright blue bike helmet-8.png"),
	
]

# Referințe către nodurile din scenă.
@onready var grid: GridContainer = $CenterContainer/GridContainer
@onready var timer: Timer = $Timer

# Cartonașele selectate de copil.
var first_card: Control = null
var second_card: Control = null

# Numărul perechilor descoperite.
var matched_pairs: int = 0

# Numărul greșelilor efectuate.
var mistakes: int = 0

# Împiedică selectarea altor cartonașe
# în timpul verificării unei perechi.
var is_checking: bool = false


func _ready() -> void:
	# Configurăm timerul să funcționeze o singură dată.
	timer.one_shot = true

	# Conectăm semnalul care se declanșează
	# când timpul de așteptare se termină.
	timer.timeout.connect(_on_timer_timeout)

	# Generăm cartonașele la pornirea jocului.
	create_cards()


func create_cards() -> void:
	# Lista ID-urilor pe care le vom distribui.
	var card_ids: Array[int] = []

	# Pentru fiecare imagine, introducem ID-ul de două ori.
	# Astfel, fiecare imagine va avea o pereche.
	for i in range(card_textures.size()):
		card_ids.append(i)
		card_ids.append(i)

	# Amestecăm aleatoriu pozițiile.
	card_ids.shuffle()

	# Generăm câte un cartonaș pentru fiecare ID.
	for id in card_ids:
		var card = CARD_SCENE.instantiate()

		# Asociem ID-ul și imaginea corespunzătoare.
		card.setup(id, card_textures[id])

		# Adăugăm cartonașul în grilă.
		grid.add_child(card)

		# Conectăm semnalul cartonașului la scena principală.
		card.card_flipped.connect(_on_card_flipped)


# Apelată automat când un cartonaș este întors.
func _on_card_flipped(card: Control) -> void:
	# Nu acceptăm cartonașe noi în timpul verificării.
	if is_checking:
		return

	# Memorăm primul cartonaș selectat.
	if first_card == null:
		first_card = card
		return

	# Memorăm al doilea cartonaș.
	second_card = card
	is_checking = true

	# Blocăm toate cartonașele.
	lock_all_cards(true)

	# Verificăm dacă imaginile sunt identice.
	if first_card.card_id == second_card.card_id:
		first_card.mark_matched()
		second_card.mark_matched()

		matched_pairs += 1

		# Deblocăm cartonașele rămase.
		lock_all_cards(false)
		reset_selection()

		# Verificăm dacă nivelul este complet.
		if matched_pairs == card_textures.size():
			level_completed()
	else:
		# Pereche greșită.
		mistakes += 1

		# Cartonașele rămân vizibile timp de o secundă.
		# Celelalte rămân blocate până expiră timerul.
		timer.start(1.0)


# Apelată când timerul ajunge la zero.
func _on_timer_timeout() -> void:
	# Întoarcem cele două cartonașe greșite.
	first_card.show_back()
	second_card.show_back()

	# Resetăm selecția.
	reset_selection()

	# Deblocăm toate cartonașele rămase.
	lock_all_cards(false)



func reset_selection() -> void:
	first_card = null
	second_card = null
	is_checking = false


# Apelată când toate perechile au fost găsite.
func level_completed() -> void:
	print("Nivel completat!")
	print("Greșeli efectuate: ", mistakes)

# Blochează sau deblochează toate cartonașele
# care nu au fost deja asociate unei perechi.
func lock_all_cards(lock: bool) -> void:
	for card in grid.get_children():
		if not card.is_matched:
			card.is_locked = lock
