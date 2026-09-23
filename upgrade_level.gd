extends Control
@onready var background_particles = $GPUParticles2D
@onready var rays = $Anchor/Sparkle
@onready var shield = $Anchor/Shield
@onready var level = $Anchor/Shield/Level
@onready var level_nb = $Anchor/Shield/LevelNb
@onready var level_up = $Anchor/LevelUp
@onready var ribbon = $Ribbon
@onready var rewards = $Ribbon/Rewards
@onready var button_container = $HBoxContainer
@onready var title = $Title
var tween : Tween
var tween_ray : Tween
var tween_buttons: Tween
func _ready() -> void:
	title.self_modulate.a = 0.0
	background_particles.emitting = false
	rays.scale = Vector2.ZERO
	shield.scale = Vector2.ZERO
	level.self_modulate.a = 0.0
	level_nb.self_modulate.a = 0.0
	level_nb.text = "0"
	level_up.self_modulate.a = 0.0
	ribbon.scale.x = 0.0
	rewards.self_modulate.a = 0.0
	for child in button_container.get_children():
		child.modulate.a = 0.0
	animate()

func animate() -> void:
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_ray = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween_ray.set_loops()
	tween_ray.tween_property(rays, "rotation_degrees", 360.0, 8.0).from(0.0)
	tween.tween_interval(1.0)
	tween.tween_property(title, "self_modulate:a", 1.0, 0.8)
	# Rays and shield
	tween.parallel().tween_callback(background_particles.restart)
	tween.parallel().tween_property(rays, "scale", Vector2.ONE, 0.45).from(Vector2.ZERO)
	tween.parallel().tween_property(shield, "scale", Vector2.ONE, 1.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(shield.material, "shader_parameter/y_rot", 360.0, 1.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Labels
	tween.parallel().tween_property(level, "self_modulate:a", 1.0, 1.5)
	tween.parallel().tween_property(level_nb, "self_modulate:a", 1.0, 1.5)
	tween.tween_method(count_up.bind(level_nb), 0, ControlLevel.get_level(HourActivity.activities), 1.5)
	tween.tween_property(level_up, "self_modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(level_up, "position:y", level_up.position.y, 0.8).from(level_up.position.y - 150)
	
	# Ribbon
	tween.tween_property(ribbon, "scale:x", 0.75, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(rewards, "self_modulate:a", 1.0, 1.2)
	
	# Buttons
	for child in button_container.get_children():
		tween.tween_property(child, "modulate:a", 1.0, 0.15)
		tween.parallel().tween_property(child, "position:y", position.y, 0.7).from(position.y + 200)
		tween.tween_interval(0.05)
	tween.tween_callback(start_buttons_loop)

func start_buttons_loop() -> void:
	tween_buttons = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_buttons.set_loops()
	for child in button_container.get_children():
		tween_buttons.tween_property(child, "scale", Vector2(1.1, 1.1), 0.2)
		tween_buttons.tween_property(child, "scale", Vector2(1.0, 1.0), 0.2)
	tween_buttons.tween_interval(0.4)
	
func count_up(value: int, label: Label) -> void:
	label.text = str(value)
	
func _esc() -> void:
	get_tree().change_scene_to_file("res://login.tscn")
