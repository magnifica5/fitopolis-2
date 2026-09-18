extends ScrollContainer


@onready var user_list: VBoxContainer = $VBoxContainer

var user_row_scene = preload("res://HboxLedearboard.tscn")


func _ready() -> void:
	pass

func deschide_leaderboard() -> void:
	# Pornim de sus de fiecare dată
	scroll_vertical = 0

	# Oprim orice animație veche
	var tween := create_tween()
	tween.kill()

	# Reîncărcăm utilizatorii și pornim animația
	await get_users()


func get_users() -> void:
	var children_query := SupabaseQuery.new() \
		.from("children") \
		.select(["username", "connection_code", "avatar_number"])

	var progress_query := SupabaseQuery.new() \
		.from("progres_copil") \
		.select(["activities", "connection_code"])

	# Query-uri executate în paralel
	var children_task = Supabase.database.query(children_query)
	var progress_task = Supabase.database.query(progress_query)

	var result = await children_task.completed
	var progress_result = await progress_task.completed

	if result.error:
		print("Eroare children: ", result.error)
		return

	if progress_result.error:
		print("Eroare progres_copil: ", progress_result.error)
		return

	var children = result.data
	var progress_list = progress_result.data

	var progress_by_code := {}

	for progress in progress_list:
		var code := str(progress["connection_code"]).strip_edges()
		progress_by_code[code] = int(progress["activities"])

	var users: Array = []

	for child in children:
		var connection_code := str(
			child["connection_code"]
		).strip_edges()

		var activities_completed: int = progress_by_code.get(
			connection_code,
			0
		)

		users.append({
			"username": str(child["username"]),
			"connection_code": connection_code,
			"activities_completed": activities_completed,
			"avatar_number": int(child["avatar_number"])
		})

	users.sort_custom(sort_users_by_activities)

	await display_users(users)



func sort_users_by_activities(a, b) -> bool:
	return a["activities_completed"] > b["activities_completed"]


func display_users(users: Array) -> void:
	var current_row: Control = null
	var existing_children = user_list.get_children()

	# Presupunem că primul copil este headerul
	for index in range(1, existing_children.size()):
		existing_children[index].queue_free()

	await get_tree().process_frame

	var current_connection_code := str(Globals.code).strip_edges()

	for i in range(users.size()):
		var user = users[i]

		var row = user_row_scene.instantiate()
		user_list.add_child(row)

		row.setup(
			i + 1,
			str(user["username"]),
			int(user["activities_completed"]),
			int(user["avatar_number"])
		)

		if str(user["connection_code"]).strip_edges() == current_connection_code:
			current_row = row

	await get_tree().process_frame
	await get_tree().process_frame

	if current_row != null:
		await scroll_to_current_row(current_row)
	else:
		print("Nu am găsit utilizatorul curent în leaderboard.")


func scroll_to_current_row(row: Control) -> void:
	var row_y := row.position.y
	var row_height := row.size.y
	var viewport_height := size.y

	var target_scroll := row_y - (
		viewport_height - row_height
	) / 2.0

	var scrollbar := get_v_scroll_bar()

	target_scroll = clamp(
		target_scroll,
		0.0,
		scrollbar.max_value
	)

	var tween := create_tween()

	tween.tween_property(
		self,
		"scroll_vertical",
		int(target_scroll),
		0.7
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await tween.finished

	if row.has_method("highlight_current_player"):
		row.highlight_current_player()
