extends Button

@onready var sprite_on: Sprite2D = $SpriteOn
@onready var sprite_off: Sprite2D = $SpriteOff

func _ready() -> void:
	# Căutăm indexul bus-ului principal de sunet ("Master")
	var master_bus_index = AudioServer.get_bus_index("Master")
	
	# Setăm starea butonului bazat pe valoarea globală salvată
	button_pressed = Globals.is_audio_on
	
	# Conectăm semnalul 'toggled'
	toggled.connect(_on_button_toggled)
	
	# Actualizăm starea inițială
	_set_sound_state(Globals.is_audio_on)

func _on_button_toggled(is_on: bool) -> void:
	Globals.is_audio_on = is_on
	_set_sound_state(is_on)

func _set_sound_state(is_on: bool) -> void:
	# 1. Actualizăm imaginea
	sprite_on.visible = is_on
	sprite_off.visible = !is_on
	
	# 2. Oprim / Pornim tot sunetul din joc (Mute / Unmute)
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_index, not is_on)
