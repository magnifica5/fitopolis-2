extends Button

@export_range(1, 9) var number: int = 1

@onready var game = get_node("../..")

func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	game.set_number(number)
