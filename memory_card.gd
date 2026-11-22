
extends Control

# Semnal emis atunci când utilizatorul întoarce un cartonaș.
# Scena principală va primi cartonașul apăsat și va verifica perechile.
signal card_flipped(card)


# Referințe către cele două imagini ale cartonașului.
# @onready înseamnă că variabilele sunt inițializate când nodul este pregătit.
@onready var front: TextureRect = $Front
@onready var back: TextureRect = $Back


# ID-ul imaginii. Două cartonașe cu același ID formează o pereche.
var card_id: int = -1

# true dacă imaginea din față este vizibilă.
var is_flipped: bool = false

# true dacă perechea a fost deja găsită.
var is_matched: bool = false

# true dacă utilizatorul nu mai are voie să apese cartonașul.
var is_locked: bool = false

# Păstrăm temporar textura dacă setup() este apelată
# înainte ca nodurile Front și Back să fie pregătite.
var _pending_texture: Texture2D = null


# Funcția este apelată automat când nodul intră în scenă.
func _ready() -> void:

	# Stabilim dimensiunea minimă a cartonașului.
	# Este utilă atunci când cartonașele sunt într-un GridContainer.
	custom_minimum_size = Vector2(256, 256)

	# Imaginile nu vor intercepta apăsările.
	# Astfel, nodul MemoryCard poate detecta clickurile.
	front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Dacă imaginea a fost atribuită înainte de _ready(),
	# o aplicăm acum nodului Front.
	if _pending_texture != null:
		front.texture = _pending_texture

	# La început, cartonașul este întors cu spatele.
	show_back()


# Detectează interacțiunea utilizatorului cu cartonașul.
func _gui_input(event: InputEvent) -> void:

	# Verificăm dacă evenimentul este o apăsare de mouse.
	# Pe telefoane, atingerea poate genera și un astfel de eveniment.
	if event is InputEventMouseButton:

		# Acceptăm doar apăsarea butonului stâng.
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# Nu întoarcem un cartonaș deja descoperit,
			# deja asociat unei perechi sau blocat temporar.
			if not is_flipped and not is_matched and not is_locked:

				# Întoarcem cartonașul cu fața în sus.
				flip_card()

				# Anunțăm scena principală că a fost întors.
				card_flipped.emit(self)


# Configurează cartonașul cu un ID și o imagine.
# Va fi apelată de scena principală când generăm perechile.
func setup(id: int, texture: Texture2D) -> void:

	# Memorăm ID-ul imaginii.
	card_id = id

	# Dacă nodul este deja pregătit, schimbăm direct textura.
	if is_node_ready():
		front.texture = texture
	else:
		# Altfel, păstrăm textura până la apelarea _ready().
		_pending_texture = texture


# Întoarce cartonașul cu fața în sus.
func flip_card() -> void:

	# Nu facem nimic dacă este deja întors
	# sau dacă aparține unei perechi găsite.
	if is_flipped or is_matched:
		return

	# Actualizăm starea cartonașului.
	is_flipped = true

	# Arătăm imaginea din față și ascundem spatele.
	front.visible = true
	back.visible = false


# Întoarce cartonașul cu spatele în sus.
func show_back() -> void:

	# Cartonașul nu mai este considerat întors.
	is_flipped = false

	# Ascundem imaginea și afișăm spatele.
	front.visible = false
	back.visible = true


# Marchează cartonașul ca parte a unei perechi corecte.
func mark_matched() -> void:

	# Perechea a fost găsită.
	is_matched = true

	# Blocăm interacțiunile ulterioare.
	is_locked = true

	# Cartonașul rămâne cu imaginea vizibilă.
	is_flipped = true
	front.visible = true
	back.visible = false
