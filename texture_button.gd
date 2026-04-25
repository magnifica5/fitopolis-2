extends TextureButton
@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(HourActivity._on_choose_activity)
			
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
		
		
	
