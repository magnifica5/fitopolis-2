extends Node2D
var layers_hidden := false
var main_scene = "res://login.tscn"
var shop = "res://shop_oras.tscn"
# Durata fade-ului (în secunde)
var fade_duration := 1.5
# Delay înainte de fade (în secunde)
var fade_delay := 0.5

func _process(_delta):
	#if Input.is_action_just_pressed("fade_layer"):
		#toggle_layers()
		pass

#func toggle_layers():
	#layers_hidden = !layers_hidden
	#for layer in layers:
		#var tween = create_tween()
		#tween.tween_interval(fade_delay) # delay înainte de fade
		#var target_alpha = 0.0 if layers_hidden else 1.0
		#tween.tween_property(
			#layer,
			#"modulate",
			#Color(layer.modulate.r, layer.modulate.g, layer.modulate.b, target_alpha),
			#fade_duration
		#)

func _ready():
	preload_scene(main_scene)
	preload_scene(shop)
	pass

func preload_scene(path: String):
	ResourceLoader.load_threaded_request(path)

func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null

func _acasa_pressed() -> void:
	var ready = get_scene(main_scene)
	if ready:
		#$AudioStreamPlayer.play()
		#await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_packed(ready)
	
func _catre_shop() -> void:
	var ready = get_scene(shop)
	if ready:
		#$AudioStreamPlayer.play()
		#await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_packed(ready)
	
