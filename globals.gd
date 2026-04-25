#JSON = translator între „limba fișierelor” și „limba codului tău”.
#
#stringify = „convertesc dicționarul meu într-un text pe care îl pot scrie în fișier”
#
#parse_string = „citesc textul din fișier și îl fac din nou dicționar ca să îl pot folosi în joc”
#JSON = JavaScript Object Notation
extends Node
var trezire = 0
var completeaza = 0
var ex = 0
var code
var dejun = 0
var pranz = 0
var ex2 = 0
var cina = 0
var somn = 0
var parinte
var parola
var channel_exists = 0
var email
var codep
signal verif_trezire
signal verif_ex
signal final_settings
var path_hours = "user://hours.save"
var verif_hours = 0
var avertisment_vizualizat: bool = false
var personaj = -1
var score = 0
var obiecte_cumparate = {}
func _ready():
	var path = "user://avertisment.save"
	if FileAccess.file_exists(path):
		avertisment_vizualizat = true
	else:
		avertisment_vizualizat = false
		
func marcheaza_cumparat(id):
	var path = "user://stikere.save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		obiecte_cumparate = JSON.parse_string(content)
	obiecte_cumparate[id] = true
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(obiecte_cumparate))
	file.close()


func este_cumparat(id):
	var path = "user://stikere.save"
	if not FileAccess.file_exists(path):
		return false
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	if data == null:
		return false
	return data.has(id)
	
func salveaza_avertisment():
	var data = {}
	var path = "user://avertisment.save"
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_line("vizualizat=true")
	f.close()
	if FileAccess.file_exists(path_hours):
		var file = FileAccess.open(path_hours, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result:
			data = result
	data["trezire"] = trezire
	data["ex"] = ex
	data["dejun"] = dejun
	data["pranz"] = pranz
	data["ex2"] = ex2
	data["cina"] = cina
	data["somn"] = somn
	data["channel"] = channel_exists
	data["parinte"] = parinte
	data["score"] = 200
	avertisment_vizualizat = true
	var file = FileAccess.open(path_hours, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
func load_hours():
	if not FileAccess.file_exists(path_hours): #daca nu exista, (e mai mult de siguranta, exista mereu)
		return
	var file = FileAccess.open(path_hours, FileAccess.READ)
	if file:
		var content = file.get_as_text() # preia textul, stringul
		file.close()
		var result = JSON.parse_string(content) #il face dictionar
		if result:
			trezire = result.get("trezire", trezire) #foloseste metoda get ca in python ca sa gaseasca
			ex = result.get("ex", ex)
			dejun = result.get("dejun", dejun)
			pranz = result.get("pranz", pranz)
			ex2 = result.get("ex2", ex2)
			cina = result.get("cina", cina)
			somn = result.get("somn", somn)
			parinte = result.get("parinte", parinte)
			channel_exists = result.get("channel", channel_exists)
			
func adauga_personaj(valoare: int):
	var data_existenta = {}
	if FileAccess.file_exists(path_hours): # verifica daca exista
		var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		var content = file.get_as_text() #ia ca string
		file.close()
		var result = JSON.parse_string(content) #transforma in dictionar
		if result:
			data_existenta = result #egaleaza ce era cu noul dictionar din functie
	else:
		data_existenta = {}
	data_existenta["personaj"] = valoare #atribuie dictionarului cheia pe care o vreau
	personaj = valoare
	var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	file.close()

func adauga_email(valoare: String):
	var data_existenta = {}
	if FileAccess.file_exists(path_hours): # verifica daca exista
		var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		var content = file.get_as_text() #ia ca string
		file.close()
		var result = JSON.parse_string(content) #transforma in dictionar
		if result:
			data_existenta = result #egaleaza ce era cu noul dictionar din functie
	else:
		data_existenta = {}
	data_existenta["email"] = valoare #atribuie dictionarului cheia pe care o vreau
	email = valoare
	var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	file.close()

func adauga_channel(valoare: int):
	var data_existenta = {}
	if FileAccess.file_exists(path_hours): # verifica daca exista
		var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		var content = file.get_as_text() #ia ca string
		file.close()
		var result = JSON.parse_string(content) #transforma in dictionar
		if result:
			data_existenta = result #egaleaza ce era cu noul dictionar din functie
	else:
		data_existenta = {}
	data_existenta["channel"] = valoare #atribuie dictionarului cheia pe care o vreau
	channel_exists = valoare
	var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	file.close()
	
func adauga_parola(valoare: String):
	var data_existenta = {}
	if FileAccess.file_exists(path_hours):
		var file = FileAccess.open(path_hours, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result:
			data_existenta = result
	else:
		data_existenta = {}
	data_existenta["parola"] = valoare
	parola = valoare
	var file = FileAccess.open(path_hours, FileAccess.WRITE) 
	file.store_string(JSON.stringify(data_existenta, "\t")) 
	file.close()

func adauga_code(valoare: String):
	var data_existenta = {}
	if FileAccess.file_exists(path_hours):
		var file = FileAccess.open(path_hours, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result:
			data_existenta = result
	else:
		data_existenta = {}
	data_existenta["code"] = valoare
	code = valoare
	var file = FileAccess.open(path_hours, FileAccess.WRITE) 
	file.store_string(JSON.stringify(data_existenta, "\t")) 
	file.close()

func adauga_codep(valoare: String):
	var data_existenta = {}
	if FileAccess.file_exists(path_hours):
		var file = FileAccess.open(path_hours, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result:
			data_existenta = result
	else:
		data_existenta = {}
	data_existenta["codep"] = valoare
	codep = valoare
	var file = FileAccess.open(path_hours, FileAccess.WRITE) 
	file.store_string(JSON.stringify(data_existenta, "\t")) 
	file.close()
	
	
func adauga_scor(valoare: int):
	var data_existenta = {}
	if FileAccess.file_exists(path_hours): # verifica daca exista
		var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		var content = file.get_as_text() #ia ca string
		file.close()
		var result = JSON.parse_string(content) #transforma in dictionar
		if result:
			data_existenta = result #egaleaza ce era cu noul dictionar din functie
	else:
		data_existenta = {}
	if data_existenta.has("score"):
		data_existenta["score"] += valoare
	else:
		data_existenta["score"] = valoare #atribuie dictionarului cheia pe care o vreau
	score += valoare
	var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	file.close()
	
func scade_scor(valoare: int):
	var data_existenta = {}
	if FileAccess.file_exists(path_hours): # verifica daca exista
		var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		var content = file.get_as_text() #ia ca string
		file.close()
		var result = JSON.parse_string(content) #transforma in dictionar
		if result:
			data_existenta = result #egaleaza ce era cu noul dictionar din functie
	else:
		data_existenta = {}
	if data_existenta.has("score"):
		data_existenta["score"] -= valoare
		score -= valoare
	var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	file.close()
	
func citeste_personaj():
	var file = FileAccess.open(path_hours, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return int(valori["personaj"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia

func citeste_code():
	var file = FileAccess.open(path_hours, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return String(valori["code"])

func citeste_codep():
	var file = FileAccess.open(path_hours, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return String(valori["codep"])

func citeste_email():
	var file = FileAccess.open(path_hours, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return String(valori["email"])

func citeste_score():
	var file = FileAccess.open(path_hours, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return int(valori["score"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia
	
func citeste_parola():
	var file = FileAccess.open(path_hours, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return str(valori["parola"])

func citeste_channel():
	var file = FileAccess.open(path_hours, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return str(valori["channel"])
	
