extends CanvasLayer
@onready var foto = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	foto.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _final_dinti() -> void:
	foto.visible = true
