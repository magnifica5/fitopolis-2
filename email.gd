extends Node2D
@onready var http_request = $HTTPRequest
var email = ""
var code
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	code = str(randi_range(1000, 9999))
	Globals.adauga_code(code)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_complete_pressed() -> void:
	email = Globals.citeste_email()
	trimite_mail(email, code)
	
func trimite_mail(email: String, code: String):
	var url = "http://127.0.0.1:5000/trimite"#"https://python-fit-o-polis.onrender.com/trimite" #"https://server-python-fitopolis.onrender.com/trimite"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer f1t0p0l110"
	]
	var data = {
		"email": email,
		"type": "verification",
		"code": code
	}
	var json_data = JSON.stringify(data)
	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_data
	)
	if error != OK:
		print("Eroare la request:", error)
	

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Status:", response_code)
	print("Raspuns server:", body.get_string_from_utf8())
	if response_code == 200:
		$AudioStreamPlayer.play()
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://code_email.tscn")
