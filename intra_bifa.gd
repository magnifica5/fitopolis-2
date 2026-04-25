extends Node2D
@onready var http_request = $HTTPRequest
var activitati = []
var nra = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var email = Globals.citeste_email()
	HourActivity.load_progress()
	if HourActivity.complete_trezire == 1:
		activitati.append("Programul de dimineață")
		nra += 1
	if HourActivity.complete_dejun == 1:
		activitati.append("Masa de dimineață")
		nra += 1
	if HourActivity.complete_ex == 1:
		activitati.append("Exercițiile de dimineață")
		nra += 1
	if HourActivity.complete_pranz == 1:
		activitati.append("Masa de prânz")
		nra += 1
	if HourActivity.complete_ex2 == 1:
		activitati.append("Exerciții după-amiază")
		nra += 1
	if HourActivity.complete_cina == 1:
		activitati.append("Masa de seară")
		nra += 1
	if HourActivity.complete_somn == 1:
		activitati.append("Programul de somn")
		nra += 1
	if nra == 0:
		activitati.append("Copilul nu a facut nicio activitate azi.")
	trimite_mail(email, activitati)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func trimite_mail(email: String, activi: Array):
	var url = "http://127.0.0.1:5000/trimite"#"https://python-fit-o-polis.onrender.com/trimite"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer f1t0p0l110"
	]
	var data = {
		"email": email,
		"activitati": activi,
		"type": "daily"
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
	


func _catre_verificare() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://bifeaza_activi.tscn")


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Status:", response_code)
	print("Raspuns server:", body.get_string_from_utf8())
