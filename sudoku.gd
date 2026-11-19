extends Control

@onready var grid_container: GridContainer = $CenterContainer/GridContainer
var board_data=[]

var starting_board=[
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
var selected_cell:Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_data.resize(81)
	board_data.fill(0)
	create_board()
func create_board():
	for i in range(81):
		var btn=Button.new()
		if(starting_board[i] != 0):
			btn.text=str(starting_board[i])
			btn.disabled=true
		board_data[i]=starting_board[i]
		btn.custom_minimum_size=Vector2(50,50)
		btn.pressed.connect(on_pressed_selected_cell.bind(btn))
		grid_container.add_child(btn)

func on_pressed_selected_cell(btn):
	if(selected_cell!=null):
		selected_cell.modulate = Color.WHITE
	selected_cell=btn
	print("button selected")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
