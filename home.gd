extends Control
@onready var username = $HBoxContainer/VBoxContainer2/HBoxContainer/Label2
@onready var cod = $HBoxContainer/VBoxContainer2/HBoxContainer2/Label3
@onready var scor = $Panel/HBoxContainer/Label2
@onready var activ = $Panel/HBoxContainer2/Label3
@onready var days = $Panel2/Label2
@onready var avatar_final = $HBoxContainer/VBoxContainer/PanelContainer/TextureButton
@onready var activity = $Panel/HBoxContainer2/Label3
var sprite_sheet := preload("res://assets/animals.png")
var cols := 7
var rows := 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = Supabase.auth.client
	if parent == null: return
	var query = SupabaseQuery.new().from("children").select().eq("username", Globals.username)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null:
		var d = result.data
		var data = d[0]
		var date = data.created_at
		var date_dict = Time.get_datetime_dict_from_datetime_string(date, false)
		var creation_day = int(date_dict["day"])
		var data_acum = Time.get_datetime_dict_from_system()
		data_acum = data_acum["day"]
		days.text = str(int(data_acum) - creation_day)
		username.text = data.username
		cod.text = data.connection_code
		Globals.adauga_code(data.connection_code)
		scor.text = str(int(data.scor))
		var avatar = int(data.avatar_number)
		var sheet_size = sprite_sheet.get_size()
		var cell_size = sheet_size / Vector2(cols, rows)
		var row = int(avatar / cols)
		var col = avatar % cols
		var atlas = AtlasTexture.new()
		atlas.atlas = sprite_sheet
		atlas.region = Rect2(Vector2(col, row) * cell_size, cell_size)
		avatar_final.texture_normal = atlas
		avatar_final.texture_pressed = atlas
		avatar_final.texture_hover = atlas
		avatar_final.texture_focused = atlas
		avatar_final.texture_disabled = atlas
	var query_activity = SupabaseQuery.new().from("progres_copil").select(["missed"]).eq("connection_code", Globals.citeste_code())
	var task_activity = Supabase.database.query(query_activity)
	var result_activity = await task_activity.completed
	if result_activity.error == null:
		var data = result_activity.data
		data = data[0]
		var value = int(100 - int(data.missed / 7 * 100))
		activity.text = str(value) + "%"
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
