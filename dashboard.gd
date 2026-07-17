extends Control
@onready var home = $HBoxContainer/Panel/VBoxContainer/TextureButton
@onready var settings = $HBoxContainer/Panel/VBoxContainer/TextureButton2
@onready var reports = $HBoxContainer/Panel/VBoxContainer/TextureButton3
@onready var schedule = $HBoxContainer/Panel/VBoxContainer/TextureButton4
@onready var tabs = $HBoxContainer/MarginContainer/TabContainer
@onready var lacat = $HBoxContainer/MarginContainer/TabContainer/Control3/Panel4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tabs.current_tab = 0
	lacat.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_home_pressed() -> void:
	tabs.current_tab = 0
	
func _on_settings_pressed() -> void:
	tabs.current_tab = 1

func _on_reports_pressed() -> void:
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select(["verificare"]).eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null:
		var data = result.data[0]
		if data.verificare != null:
			var ora = change_type(data.verificare)
			var ora_curenta = Time.get_datetime_dict_from_system()
			var mins = ora_curenta.hour * 60 + ora_curenta.minute
			if mins >= ora and mins <= ora + 7:
				tabs.current_tab = 2
				lacat.hide()
			else:
				lacat.show()
				tabs.current_tab = 2
				print("merge")
		else:
			lacat.show()
			tabs.current_tab = 2
	else:
		print(result.error.message)

func _on_schedule_pressed() -> void:
	tabs.current_tab = 3


func _catre_login() -> void:
	get_tree().change_scene_to_file("res://background_login.tscn")


func _back() -> void:
	get_tree().change_scene_to_file("res://interfata_parinte.tscn")

func change_type(string):
	var parti = string.split(":")
	var ore = parti[0].to_int()
	var minute = parti[1].to_int()
	var total_minute = (ore * 60) + minute
	return total_minute
