extends TextureButton
var shop = "res://shop_oras.tscn";
func _ready() -> void:
	preload_scene(shop)
	pressed.connect(_on_pressed)
	
func preload_scene(path: String):
	ResourceLoader.load_threaded_request(path)

func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null
	
func _on_pressed() -> void:
	var ready = get_scene(shop)
	if ready:
		$AudioStreamPlayer.play()
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_packed(shop)
