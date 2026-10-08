extends Control
var oras = "res://oras2.0.tscn"
func _ready() -> void:
	preload_scene(oras)

func preload_scene(path: String):
	ResourceLoader.load_threaded_request(path)

func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null

func _catre_oras() -> void:
	var ready = get_scene(oras)
	if ready:
		get_tree().change_scene_to_packed(ready)
