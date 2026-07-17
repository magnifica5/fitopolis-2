extends Control
@onready var b1 = $ScrollContainer/VBoxContainer/HBoxContainer/CheckBox
@onready var b2 = $ScrollContainer/VBoxContainer/HBoxContainer2/CheckBox
@onready var b3 = $ScrollContainer/VBoxContainer/HBoxContainer8/CheckBox
@onready var b4 = $ScrollContainer/VBoxContainer/HBoxContainer3/CheckBox
@onready var b5 = $ScrollContainer/VBoxContainer/HBoxContainer4/CheckBox
@onready var b6 = $ScrollContainer/VBoxContainer/HBoxContainer5/CheckBox
@onready var b7 = $ScrollContainer/VBoxContainer/HBoxContainer6/CheckBox
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _back_to_start() -> void:
	var score = 0
	var missed = 0
	if b1.button_pressed and HourActivity.complete_trezire == 1:
		score += 200
		HourActivity.complete_trezire = 0
		print("score1")
	else:
		HourActivity.complete_trezire = 0
		missed += 1
		print("s1")
	if b2.button_pressed and HourActivity.complete_ex == 1:
		print("score2")
		HourActivity.complete_ex = 0
		score += 200
	else:
		HourActivity.complete_ex = 0
		missed += 1
		print("s2")
	if b3.button_pressed and HourActivity.complete_dejun == 1:
		print("score3")
		score += 200
		HourActivity.complete_dejun = 0
	else:
		missed += 1
		HourActivity.complete_dejun = 0
		print("s3")
	if b4.button_pressed and HourActivity.complete_pranz == 1:
		print("score4")
		score += 200
		HourActivity.complete_pranz = 0
	else:
		missed += 1
		HourActivity.complete_pranz = 0
		print("s4")
	if b5.button_pressed and HourActivity.complete_ex2 == 1:
		print("score5")
		HourActivity.complete_ex2 = 0
		score += 200
	else:
		HourActivity.complete_ex2 = 0
		missed += 1
		print("s5")
	if b6.button_pressed and HourActivity.complete_cina == 1:
		print("score6")
		score += 200
		HourActivity.complete_cina = 0
	else:
		missed += 1
		HourActivity.complete_cina = 0
		print("s6")
	if b7.button_pressed and HourActivity.complete_somn == 1:
		print("score7")
		score += 200
		HourActivity.complete_somn = 0
	else:
		HourActivity.complete_somn = 0
		missed += 1
		print("s7")
	HourActivity.missed = missed
	var query1 = SupabaseQuery.new().from("children").select(["scor"]).eq("connection_code", Globals.citeste_code())
	var task1 = Supabase.database.query(query1)
	var result1 = await task1.completed
	if result1.error == null:
		var score_initial = result1.data[0]
		score_initial = score_initial.scor
		Globals.score = score + score_initial
		var query = SupabaseQuery.new().from("children").update({"scor": int(Globals.score)}).eq("connection_code", str(Globals.code))
		var task = Supabase.database.query(query)
		var result_base = await task.completed
		if result_base.error == null:
			print("update reusit")
		else:
			print(result_base.error.message)
		await HourActivity.save_progress()
	else:
		print(result1.error.message)
