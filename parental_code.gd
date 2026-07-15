extends Control
@onready var parental_code = $CanvasLayer3/Panel/LineEdit
@onready var errors = $CanvasLayer3/Panel/Label2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_verifica() -> void:
	var code = parental_code.text.strip_edges()
	var query := SupabaseQuery.new()
	query.from("children").select(["connection_code"]).eq("connection_code", code)
	var task = Supabase.database.query(query)
	var response = await task.completed
	if response.error:
		print("Eroare la verificarea codului: ", response.error.message)
		return
	if response.data.size() > 0:
		print("Cod valid! Am găsit utilizatorul cu ID-ul: ")
		Globals.adauga_code(code)
		errors.text = ""
		get_tree().change_scene_to_file("res://alege_personaj.tscn")
	else:
		errors.text = "Codul introdus nu este valid."
