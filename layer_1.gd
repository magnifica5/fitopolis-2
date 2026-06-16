extends TileMapLayer

@export var source_id := 0

var current_atlas = Vector2i(0, 0)

func _process(delta):

	if Input.is_action_pressed("click"):

		var mouse_pos = get_global_mouse_position()

		var cell = local_to_map(mouse_pos)

		set_cell(cell, source_id, current_atlas)
