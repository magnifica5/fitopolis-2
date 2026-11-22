extends Control

@onready var grid_container: GridContainer = $GridContainer

@export var cell_size: int = 80
@export var font_size: int = 35

var board_data = []

var starting_board = [
	0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,
]

var selected_cell: Button = null
var selected_index: int = -1

func _ready() -> void:
	board_data.resize(81)
	board_data.fill(0)
	create_board()


func create_board():
	for i in range(81):
		var btn = Button.new()

		if starting_board[i] != 0:
			btn.text = str(starting_board[i])
			btn.disabled = true

		board_data[i] = starting_board[i]

		# Dimensiunea celulei
		btn.custom_minimum_size = Vector2(cell_size, cell_size)

		# Dimensiunea fontului
		btn.add_theme_font_size_override("font_size", font_size)

		btn.pressed.connect(on_pressed_selected_cell.bind(btn, i))

		grid_container.add_child(btn)


func on_pressed_selected_cell(btn: Button, index: int):
	if selected_cell != null:
		selected_cell.modulate = Color.WHITE

	selected_cell = btn
	selected_index = index

	selected_cell.modulate = Color.YELLOW

	print("button selected")


func set_number(number: int):
	if selected_cell == null:
		return

	selected_cell.text = str(number)

	board_data[selected_index] = number

	print("Number inserted: ", number)
