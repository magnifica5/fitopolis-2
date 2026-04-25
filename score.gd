extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var score = Globals.citeste_score()
	self.text = str(int(score))
	#var data_existenta = {}
	#var path_hours = "user://hours.save"
	#var file = FileAccess.open(path_hours, FileAccess.READ)
	#var content = file.get_as_text() #ia ca string
	#file.close()
	#var result = JSON.parse_string(content) #transforma in dictionar
	#if result:
		#data_existenta = result 
	#if data_existenta.has("score"):
		#Globals.scade_scor(50)
		#self.text = str(int(data_existenta["score"]))
	#else:
		#self.text = "0"   # creeaza 2 scriputri diferite pt scazut score si adaugat score


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_modificare() -> void:
	var score = Globals.citeste_score()
	self.text = str(int(score))


func _on_area_2d_2_modificare() -> void:
	var score = Globals.citeste_score()
	self.text = str(int(score))


func _on_area_2d_3_modificare() -> void:
	var score = Globals.citeste_score()
	self.text = str(int(score))


func _modificare() -> void:
	var score = Globals.citeste_score()
	self.text = str(int(score))
