#extends Control
#@onready var b1 = $ScrollContainer/VBoxContainer/HBoxContainer/CheckBox
#@onready var b2 = $ScrollContainer/VBoxContainer/HBoxContainer2/CheckBox
#@onready var b3 = $ScrollContainer/VBoxContainer/HBoxContainer8/CheckBox
#@onready var b4 = $ScrollContainer/VBoxContainer/HBoxContainer3/CheckBox
#@onready var b5 = $ScrollContainer/VBoxContainer/HBoxContainer4/CheckBox
#@onready var b6 = $ScrollContainer/VBoxContainer/HBoxContainer5/CheckBox
#@onready var b7 = $ScrollContainer/VBoxContainer/HBoxContainer6/CheckBox
#@onready var succes = $Panel5
#@onready var lacat = $Panel4
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#succes.hide()
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
#
#func _back_to_start() -> void:
	#await SyncManager.sync_data()
	#var score = 0
	#var missed = 0
	#var activities = 0
	#if b1.button_pressed and HourActivity.complete_trezire == 1:
		#score += 200
		#activities += 1
		#HourActivity.complete_trezire = 0
		#print("score1")
	#else:
		#HourActivity.complete_trezire = 0
		#missed += 1
		#print("s1")
	#if b2.button_pressed and HourActivity.complete_ex == 1:
		#print("score2")
		#HourActivity.complete_ex = 0
		#activities += 1
		#score += 200
	#else:
		#HourActivity.complete_ex = 0
		#missed += 1
		#print("s2")
	#if b3.button_pressed and HourActivity.complete_dejun == 1:
		#print("score3")
		#activities += 1
		#score += 200
		#HourActivity.complete_dejun = 0
	#else:
		#missed += 1
		#HourActivity.complete_dejun = 0
		#print("s3")
	#if b4.button_pressed and HourActivity.complete_pranz == 1:
		#print("score4")
		#activities += 1
		#score += 200
		#HourActivity.complete_pranz = 0
	#else:
		#missed += 1
		#HourActivity.complete_pranz = 0
		#print("s4")
	#if b5.button_pressed and HourActivity.complete_ex2 == 1:
		#print("score5")
		#activities += 1
		#HourActivity.complete_ex2 = 0
		#score += 200
	#else:
		#HourActivity.complete_ex2 = 0
		#missed += 1
		#print("s5")
	#if b6.button_pressed and HourActivity.complete_cina == 1:
		#print("score6")
		#activities += 1
		#score += 200
		#HourActivity.complete_cina = 0
	#else:
		#missed += 1
		#HourActivity.complete_cina = 0
		#print("s6")
	#if b7.button_pressed and HourActivity.complete_somn == 1:
		#print("score7")
		#activities += 1
		#score += 200
		#HourActivity.complete_somn = 0
	#else:
		#HourActivity.complete_somn = 0
		#missed += 1
		#print("s7")
	#HourActivity.missed = missed
	#HourActivity.activities += activities
	#print(missed)
	#var query1 = SupabaseQuery.new().from("children").select(["scor"]).eq("connection_code", Globals.citeste_code())
	#var task1 = Supabase.database.query(query1)
	#var result1 = await task1.completed
	#if result1.error == null:
		#var score_initial = result1.data[0]
		#score_initial = score_initial.scor
		#Globals.score = score + score_initial
		#var query = SupabaseQuery.new().from("children").update({"scor": int(Globals.score)}).eq("connection_code", str(Globals.code))
		#var task = Supabase.database.query(query)
		#var result_base = await task.completed
		#if result_base.error == null:
			#print("update reusit")
			#succes.show()
		#else:
			#print(result_base.error.message)
		#await HourActivity.save_progress()
	#else:
		#print(result1.error.message)
#
#
#func _close_succes() -> void:
	#lacat.show()
	#succes.hide()
extends Control
@onready var b1 = $ScrollContainer/VBoxContainer/HBoxContainer/CheckBox
@onready var b2 = $ScrollContainer/VBoxContainer/HBoxContainer2/CheckBox
@onready var b3 = $ScrollContainer/VBoxContainer/HBoxContainer8/CheckBox
@onready var b4 = $ScrollContainer/VBoxContainer/HBoxContainer3/CheckBox
@onready var b5 = $ScrollContainer/VBoxContainer/HBoxContainer4/CheckBox
@onready var b6 = $ScrollContainer/VBoxContainer/HBoxContainer5/CheckBox
@onready var b7 = $ScrollContainer/VBoxContainer/HBoxContainer6/CheckBox
@onready var succes = $Panel5
@onready var lacat = $Panel4

const ACTIVITY_NAMES := [
	"trezire", "ex1", "masa_dimineata", "masa_pranz", "ex2", "masa_seara", "somn"
]
var _checkboxes: Array = []
var _day := ""
var _child_code := ""
var _can_confirm := false
var _busy := false

func _ready() -> void:
	_checkboxes = [b1, b2, b3, b4, b5, b6, b7]
	succes.hide()
	lacat.show()
	for box in _checkboxes:
		box.disabled = true

func _message(message: String) -> void:
	var popup := AcceptDialog.new()
	popup.title = "Confirmare activitati"
	popup.dialog_text = message
	add_child(popup)
	popup.confirmed.connect(popup.queue_free)
	popup.canceled.connect(popup.queue_free)
	preload("res://dialog_style.gd").show_dialog(popup)

func load_day() -> void:
	if _busy:
		return
	_busy = true
	_can_confirm = false
	lacat.show()
	$Panel4/Label.text = "Se verifica activitatile..."
	_child_code = str(Globals.connection_coded)
	var task = Supabase.database.Rpc(
		"fitopolis_activity_state", {"p_child_code": _child_code}
	)
	var result = await task.completed
	_busy = false
	if result.error != null:
		$Panel4/Label.text = "Nu s-au putut incarca activitatile."
		_message(str(result.error.message))
		return
	if not result.data is Dictionary:
		$Panel4/Label.text = "Raspuns invalid. Reincearca."
		return
	var data: Dictionary = result.data
	_day = str(data.get("day", ""))
	_can_confirm = bool(data.get("can_confirm", false))
	var finalized := bool(data.get("finalized", false))
	var started: Array = data.get("started", [])
	var approved: Array = data.get("approved", [])
	for i in range(_checkboxes.size()):
		_checkboxes[i].button_pressed = finalized and approved.has(ACTIVITY_NAMES[i])
		_checkboxes[i].disabled = not _can_confirm or not started.has(ACTIVITY_NAMES[i])
	lacat.visible = not _can_confirm
	if finalized:
		$Panel4/Label.text = "Ziua a fost deja confirmata."
	elif data.get("verification_time") == null:
		$Panel4/Label.text = "Configureaza ora de verificare."
	elif not _can_confirm:
		$Panel4/Label.text = "Revino la ora de verificare: " + str(data.verification_time)

func _back_to_start() -> void:
	if _busy:
		return
	if not _can_confirm or _day.is_empty():
		_message("Redeschide fila de confirmare si verifica intervalul permis.")
		return
	var selected: Array[String] = []
	for i in range(_checkboxes.size()):
		if _checkboxes[i].button_pressed and not _checkboxes[i].disabled:
			selected.append(ACTIVITY_NAMES[i])
	_busy = true
	var popup := ConfirmationDialog.new()
	popup.title = "Finalizezi ziua?"
	popup.dialog_text = "Confirmi %d activitati pentru %s?\nZiua se finalizeaza si nu mai poate fi modificata." % [selected.size(), _day]
	add_child(popup)
	popup.canceled.connect(func():
		_busy = false
		popup.queue_free()
	)
	popup.confirmed.connect(func():
		popup.queue_free()
		_submit_day(selected)
	)
	preload("res://dialog_style.gd").show_dialog(popup)

func _submit_day(selected: Array[String]) -> void:
	var task = Supabase.database.Rpc("fitopolis_confirm_day", {
		"p_child_code": _child_code,
		"p_day": _day,
		"p_activities": selected
	})
	var result = await task.completed
	_busy = false
	if result.error != null:
		_message(str(result.error.message))
		return
	if not result.data is Dictionary:
		_message("Raspunsul nu a putut fi citit. Reincearca; punctele nu se dubleaza.")
		return
	_can_confirm = false
	var data: Dictionary = result.data
	if Globals.copii.has(_child_code):
		Globals.copii[_child_code]["scor"] = int(data.get("score", 0))
		Globals.copii[_child_code]["missed"] = int(data.get("missed", 0))
		Globals.copii[_child_code]["check_verificare"] = false
		SyncManager.save_parent_data()
	$Panel5/Label.text = "Zi confirmata! Puncte acordate acum: %d" % int(data.get("new_points", 0))
	succes.show()

func _close_succes() -> void:
	succes.hide()
	lacat.show()
