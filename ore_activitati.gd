extends Control
@onready var label1 = $"ScrollContainer/VBoxContainer/HBoxContainer/LineEdit/Label-trezire"
@onready var label2 = $"ScrollContainer/VBoxContainer/HBoxContainer2/HourInput-ex/Label-ex"
@onready var label4 = $"ScrollContainer/VBoxContainer/HBoxContainer4/LineEdit/Label-pranz"
@onready var label3 = $"ScrollContainer/VBoxContainer/HBoxContainer3/HourInput-dejun/Label-dejun"
@onready var label5 = $"ScrollContainer/VBoxContainer/HBoxContainer5/LineEdit/Label-ex2"
@onready var label6 = $"ScrollContainer/VBoxContainer/HBoxContainer6/HourInput-cina/Label-cina"
@onready var label7 = $"ScrollContainer/VBoxContainer/HBoxContainer7/HourInput-somn/Label-somn"
@onready var label8 = $"ScrollContainer/VBoxContainer/HBoxContainer8/HourInput-parinte/Label-parinte"
@onready var labels = [label1, label2, label3, label4, label5, label6, label7, label8]
@onready var trezire = $ScrollContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var ex1 = $"ScrollContainer/VBoxContainer/HBoxContainer2/HourInput-ex"
@onready var dejun = $"ScrollContainer/VBoxContainer/HBoxContainer3/HourInput-dejun"
@onready var pranz = $ScrollContainer/VBoxContainer/HBoxContainer4/LineEdit
@onready var ex2 = $ScrollContainer/VBoxContainer/HBoxContainer5/LineEdit
@onready var cina = $"ScrollContainer/VBoxContainer/HBoxContainer6/HourInput-cina"
@onready var culcare = $"ScrollContainer/VBoxContainer/HBoxContainer7/HourInput-somn"
@onready var verificare = $"ScrollContainer/VBoxContainer/HBoxContainer8/HourInput-parinte"
@onready var succes = $Panel4
func _ready() -> void:
	succes.hide()
	if Globals.saved_hours == 0:
		var query = SupabaseQuery.new().from("children").select().eq("username", Globals.username)
		var task = Supabase.database.query(query)
		var result = await task.completed
		if result.error == null and result.data.size() > 0:
			var data = result.data[0]
			trezire.text = data.trezire.substr(0,5)
			ex1.text = data.ex1.substr(0, 5)
			dejun.text = data.masa_dimineata.substr(0, 5)
			pranz.text = data.masa_pranz.substr(0, 5)
			ex2.text = data.ex2.substr(0, 5)
			cina.text = data.masa_seara.substr(0, 5)
			verificare.text = data.verificare.substr(0, 5)
			culcare.text = data.culcare.substr(0, 5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_salveaza() -> void:
	var ready = true
	for label in labels:
		if label.text != "":
			ready = false
			break
	if ready:
		var new_data = {
			"trezire": trezire.text + ":00",
			"ex1": ex1.text + ":00",
			"masa_dimineata": dejun.text + ":00",
			"masa_pranz": pranz.text + ":00",
			"ex2": ex2.text + ":00",
			"masa_seara": cina.text + ":00",
			"culcare": culcare.text + ":00",
			"verificare": verificare.text + ":00"
		}
		var query = SupabaseQuery.new().from("children").update(new_data).eq("username", Globals.username)
		var task_insert = Supabase.database.query(query)
		var res_insert = await task_insert.completed
		if res_insert.error == null:
			print("success")
			succes.show()
			Globals.saved_hours = 1
		else:
			print(res_insert.error.message)
		


func _close_succes() -> void:
	succes.hide()
