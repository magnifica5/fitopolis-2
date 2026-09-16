extends ScrollContainer


@onready var user_list = $VBoxContainer

var user_row_scene = preload("res://HboxLedearboard.tscn")


func _ready():
	get_users()


func get_users():

	var children_result = SupabaseQuery.new().from("children").select(["username", "connection_code"])
	var task = Supabase.database.query(children_result)
	var result = await task.completed

	if result.error:
		print("Eroare children: ", children_result.error)
		return


	var children = result.data


	# Luăm progresul copiilor
	var progress_query = SupabaseQuery.new().from("progres_copil").select(["activities", "connection_code"])

	var progress_r = Supabase.database.query(progress_query)
	var progress_result = await progress_r.completed
	
	if progress_result.error:
		print("Eroare progres_copil: ", progress_result.error)
		return


	var progress_list = progress_result.data


	# Construim lista pentru leaderboard
	var users = []


	for child in children:

		var connection_code = child["connection_code"]

		var activities_completed = 0
		print(progress_list)
		# Găsim progresul corespunzător copilului
		for progress in progress_list:

			if progress["connection_code"] == connection_code:

				activities_completed = progress["activities"]

				break


		users.append({
			"username": child["username"],
			"activities_completed": activities_completed
		})


	# Sortăm după scor, de la cel mai mare la cel mai mic
	users.sort_custom(sort_users_by_score)


	# Afișăm
	display_users(users)


func sort_users_by_score(a, b):
	return a["activities_completed"] > b["activities_completed"]


func display_users(users: Array):

	# Ștergem rândurile existente
	for child in user_list.get_children():
		child.queue_free()


	# Creăm rând pentru fiecare utilizator
	for i in range(users.size()):

		var user = users[i]

		var row = user_row_scene.instantiate()
		user_list.add_child(row)
		row.setup(
			i + 1,
			user["username"],
			user["activities_completed"]
		)
