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
var tween : Tween
func _ready() -> void:
	background_particles.emitting = false
	rays.scale = Vector2.ZERO
	shield.scale = Vector2.ZERO
	level.self_modulate.a = 0.0
	level_nb.self_modulate.a = 0.0
	level_up.self_modulate.a = 0.0
	ribbon.scale = Vector2.ZERO
	rewards.self_modulate.a = 0.0
	button_container.self_modulate.a = 0.0
	animate()

func animate() -> void:
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(1.0)
	# Rays and shield
	tween.tween_property(rays, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(shield, "scale", Vector2.ONE, 1.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(shield.material, "shader_parameter/y_rot", 360.0, 1.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Labels
	tween.parallel().tween_property(level, "self_modulate:a", 1.0, 1.8)
	tween.parallel().tween_property(level_nb, "self_modulate:a", 1.0, 2.2)
