extends Node2D
@onready var audio = $AudioStreamPlayer
@onready var label = $CanvasLayer/TextureButton/Label
var main_scene = "res://login.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preload_scene(main_scene)

func preload_scene(path: String):
	ResourceLoader.load_threaded_request(path)

func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _back_home() -> void:
	#audio.play()
	var ready = get_scene(main_scene)
	if ready:
		get_tree().change_scene_to_packed(ready)
