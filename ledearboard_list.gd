extends ScrollContainer

@onready var user_list = $VBoxContainer

var user_row_scene = preload("res://hbox_ledearboard.gd")

func display_users(users: Array):
	for child in user_list.get_children():
		child.queue_free()

	for i in range(users.size()):
		var user = users[i]

		var row = user_row_scene.instantiate()

		row.setup(
			i + 1,
			user["username"],
			user["activities_completed"]
		)

		user_list.add_child(row)
