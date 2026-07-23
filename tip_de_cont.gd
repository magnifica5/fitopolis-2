extends Control
var path = "user://start.save"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _copil() -> void:
	get_tree().change_scene_to_file("res://autentificare_copil.tscn")



func _parinte() -> void:
	var key = Globals.get_secure_key()
	var f = FileAccess.open_encrypted(path, FileAccess.WRITE, key)
	f.store_line("parinte")
	f.close()
	get_tree().change_scene_to_file("res://background_login.tscn")
