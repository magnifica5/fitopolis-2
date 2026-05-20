extends CanvasLayer

@onready var label = $Label
@onready var timer = $Timer

signal appear_heroes

var current_text = ""
var char_index = 0
var text = ""
var speed = 0.07

@export var translation_key: String = "character"

func _ready() -> void:
	Localization.language_changed.connect(_update_text)

	timer.wait_time = speed
	timer.timeout.connect(_on_TypeTimer_timeout)

	_update_text()

func _update_text() -> void:
	text = Localization.get_text(translation_key)

	current_text = ""
	char_index = 0
	label.text = ""

	timer.start()

func _on_TypeTimer_timeout():
	if char_index < text.length():
		current_text += text[char_index]
		label.text = current_text
		char_index += 1
	else:
		timer.stop()
		appear_heroes.emit()

func _process(delta: float) -> void:
	pass
