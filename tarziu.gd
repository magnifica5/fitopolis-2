extends Node2D

@onready var rm = $miss_nutri
@onready var rs = $santos
@onready var rme = $miss_nutri_eng
@onready var rse = $santos_eng
var main_scene = "res://login.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preload_scene(main_scene)
	var personaj = Globals.citeste_personaj()
	if personaj == 1:
		if Localization.current_language == "ro":
			rm.play()
		else:
			rme.play()
	else:
		if Localization.current_language == "ro":
			rs.play()
		else:
			rse.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func preload_scene(path: String):
	ResourceLoader.load_threaded_request(path)

func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null

func _back_to_levels() -> void:
	#$AudioStreamPlayer.play()
	#await get_tree().create_timer(0.1).timeout
	var ready = get_scene(main_scene)
	if ready:
		get_tree().change_scene_to_packed(ready)
