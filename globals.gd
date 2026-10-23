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
var parinte = 0
var parola
var channel_exists = 0
var email
var codep
var saved_hours
var username
var level = 1
var copii: Dictionary = {}
signal verif_trezire
signal verif_ex
signal final_settings
var succes_inchis = false
var selected_index := -1
var where
var path_hours = "user://hours.save"
var language_path = "user://language.save"
var verif_hours = 0
var avertisment_vizualizat: bool = false
var personaj = -1
var score = 0
var obiecte_cumparate = {}
var is_audio_on: bool = true
var usernamed
var scored
var activitiesd
var badgesd = {}
var avatar_numberd
var created_atd
var connection_coded
func _ready():
	var path = "user://avertisment.save"
	if FileAccess.file_exists(path):
		avertisment_vizualizat = true
	else:
		avertisment_vizualizat = false
		
signal sticker_inventory_updated
var sticker_catalog: Dictionary = {}
var sticker_shop_ready := false
var sticker_shop_error := ""
var _sticker_context := ""
var _sticker_busy := false
var _sticker_epoch := 0

func _current_sticker_context() -> String:
	var user = Supabase.auth.client
	if user == null or not bool(user.dict.get("is_anonymous", false)):
		return ""
	if str(connection_coded).is_empty():
		return ""
	return str(user.id) + ":" + str(connection_coded)

func clear_sticker_inventory() -> void:
	_sticker_epoch += 1
	_sticker_context = ""
	sticker_shop_ready = false
	obiecte_cumparate.clear()
	sticker_catalog.clear()
	sticker_inventory_updated.emit()

func _nr_stickere() -> int:
	if not sticker_shop_ready or _sticker_context != _current_sticker_context():
		return 0
	return obiecte_cumparate.size()

func este_cumparat(id) -> bool:
	return sticker_shop_ready and _sticker_context == _current_sticker_context() and obiecte_cumparate.has(str(id))

# Compatibilitate cu codul vechi: inventarul se modifica numai din raspunsul RPC.
func marcheaza_cumparat(_id) -> void:
	push_warning("Foloseste Globals.buy_sticker(); inventarul vine de la server.")

func _apply_sticker_state(data: Dictionary, context: String) -> bool:
	if not data.get("owned") is Array or not data.get("catalog") is Dictionary or not data.has("score"):
		return false
	if str(data.get("connection_code", "")) != str(connection_coded):
		return false
	obiecte_cumparate.clear()
	for item in data.owned:
		obiecte_cumparate[str(item)] = true
	sticker_catalog = data.catalog.duplicate(true)
	scored = int(data.score)
	HourActivity.score = int(data.score)
	_sticker_context = context
	sticker_shop_ready = true
	SyncManager.save_local_data()
	sticker_inventory_updated.emit()
	return true

func refresh_stickers() -> bool:
	if _sticker_busy:
		return false
	_sticker_busy = true
	clear_sticker_inventory()
	sticker_shop_error = ""
	var context := _current_sticker_context()
	var epoch := _sticker_epoch
	if context.is_empty():
		_sticker_busy = false
		sticker_shop_error = "Conecteaza profilul copilului."
		return false
	var task = Supabase.database.Rpc("fitopolis_shop_state")
	var result = await task.completed
	_sticker_busy = false
	if epoch != _sticker_epoch or context != _current_sticker_context():
		return false
	if result.error != null:
		sticker_shop_error = str(result.error.message)
		return false
	if not result.data is Dictionary or not _apply_sticker_state(result.data, context):
		sticker_shop_error = "Inventarul nu a putut fi verificat. Reincearca."
		return false
	return true

func buy_sticker(id: String) -> Dictionary:
	if _sticker_busy:
		return {"ok": false, "message": "Asteapta finalizarea cererii curente."}
	var context := _current_sticker_context()
	if not sticker_shop_ready or context.is_empty() or context != _sticker_context:
		return {"ok": false, "message": "Redeschide magazinul pentru verificarea inventarului."}
	_sticker_busy = true
	var epoch := _sticker_epoch
	var task = Supabase.database.Rpc("fitopolis_buy_sticker", {"p_sticker_id": id})
	var result = await task.completed
	_sticker_busy = false
	if epoch != _sticker_epoch or context != _current_sticker_context():
		return {"ok": false, "message": "Sesiunea s-a schimbat. Redeschide magazinul."}
	if result.error != null:
		return {"ok": false, "message": str(result.error.message)}
	if not result.data is Dictionary or not _apply_sticker_state(result.data, context):
		return {"ok": false, "message": "Raspuns invalid. Redeschide magazinul; nu vei fi taxat de doua ori."}
	if not bool(result.data.get("ok", false)):
		return {"ok": false, "message": "Nu ai suficiente stelute pentru acest sticker."}
	return result.data

func get_secure_key() -> PackedByteArray:
	var device_id = OS.get_unique_id() # id unic al device ului
	var my_secret_salt = "Fitopolis2026"
	var combined_string = device_id + my_secret_salt
	return combined_string.sha256_buffer()

#func salveaza_avertisment():
	#var data = {}
	#var path = "user://avertisment.save"
	#var f = FileAccess.open(path, FileAccess.WRITE)
	#f.store_line("vizualizat=true")
	#f.close()
	#if FileAccess.file_exists(path_hours):
		#var file = FileAccess.open(path_hours, FileAccess.READ)
		#var content = file.get_as_text()
		#file.close()
		#var result = JSON.parse_string(content)
		#if result:
			#data = result
	#data["trezire"] = trezire
	#data["ex"] = ex
	#data["dejun"] = dejun
	#data["pranz"] = pranz
	#data["ex2"] = ex2
	#data["cina"] = cina
	#data["somn"] = somn
	#data["channel"] = channel_exists
	#data["parinte"] = parinte
	#data["score"] = 200
	#data["where"] = where
	#avertisment_vizualizat = true
	#var file = FileAccess.open(path_hours, FileAccess.WRITE)
	#file.store_string(JSON.stringify(data))
	#file.close()
#func load_hours():
	#if not FileAccess.file_exists(path_hours): #daca nu exista, (e mai mult de siguranta, exista mereu)
		#return
	#var file = FileAccess.open(path_hours, FileAccess.READ)
	#if file:
		#var content = file.get_as_text() # preia textul, stringul
		#file.close()
		#var result = JSON.parse_string(content) #il face dictionar
		#if result:
			#trezire = result.get("trezire", trezire) #foloseste metoda get ca in python ca sa gaseasca
			#ex = result.get("ex", ex)
			#dejun = result.get("dejun", dejun)
			#pranz = result.get("pranz", pranz)
			#ex2 = result.get("ex2", ex2)
			#cina = result.get("cina", cina)
			#somn = result.get("somn", somn)
			#parinte = result.get("parinte", parinte)
			#channel_exists = result.get("channel", channel_exists)
			#
func adauga_personaj(valoare: int):
	var data_existenta = {}
	var key = Globals.get_secure_key()
	if FileAccess.file_exists(path_hours): # verifica daca exista
		var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key) #citeste
		var content = file.get_as_text() #ia ca string
		file.close()
		var result = JSON.parse_string(content) #transforma in dictionar
		if result:
			data_existenta = result #egaleaza ce era cu noul dictionar din functie
	else:
		data_existenta = {}
	data_existenta["personaj"] = valoare #atribuie dictionarului cheia pe care o vreau
	data_existenta["level"] = "1"
	succes_inchis = valoare
	var file = FileAccess.open_encrypted(path_hours, FileAccess.WRITE, key) #salveaza noul dictionar
	file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	file.close()

func adauga_ex_bonus(valoare: int):
	var data_existenta = {}
	var key = Globals.get_secure_key()
	if FileAccess.file_exists(path_hours): # verifica daca exista
		var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key) #citeste
		var content = file.get_as_text() #ia ca string
		file.close()
		var result = JSON.parse_string(content) #transforma in dictionar
		if result:
			data_existenta = result #egaleaza ce era cu noul dictionar din functie
	else:
		data_existenta = {}
	data_existenta["ex_bonus"] = valoare #atribuie dictionarului cheia pe care o vreau
	var file = FileAccess.open_encrypted(path_hours, FileAccess.WRITE, key) #salveaza noul dictionar
	file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	file.close()

func adauga_username(valoare: String):
	var data_existenta = {}
	var key = Globals.get_secure_key()
	if FileAccess.file_exists(path_hours): # verifica daca exista
		var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key) #citeste
		var content = file.get_as_text() #ia ca string
		file.close()
		var result = JSON.parse_string(content) #transforma in dictionar
		if result:
			data_existenta = result #egaleaza ce era cu noul dictionar din functie
	else:
		data_existenta = {}
	data_existenta["username"] = valoare #atribuie dictionarului cheia pe care o vreau
	username = valoare
	var file = FileAccess.open_encrypted(path_hours, FileAccess.WRITE, key) #salveaza noul dictionar
	file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	file.close()
#func adauga_locatie_info(valoare: String):
	#var data_existenta = {}
	#if FileAccess.file_exists(path_hours): # verifica daca exista
		#var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		#var content = file.get_as_text() #ia ca string
		#file.close()
		#var result = JSON.parse_string(content) #transforma in dictionar
		#if result:
			#data_existenta = result #egaleaza ce era cu noul dictionar din functie
	#else:
		#data_existenta = {}
	#data_existenta["where"] = valoare #atribuie dictionarului cheia pe care o vreau
	#where = valoare
	#var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	#file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	#file.close()
#
#func adauga_email(valoare: String):
	#var data_existenta = {}
	#if FileAccess.file_exists(path_hours): # verifica daca exista
		#var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		#var content = file.get_as_text() #ia ca string
		#file.close()
		#var result = JSON.parse_string(content) #transforma in dictionar
		#if result:
			#data_existenta = result #egaleaza ce era cu noul dictionar din functie
	#else:
		#data_existenta = {}
	#data_existenta["email"] = valoare #atribuie dictionarului cheia pe care o vreau
	#email = valoare
	#var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	#file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	#file.close()
#
#func adauga_channel(valoare: int):
	#var data_existenta = {}
	#if FileAccess.file_exists(path_hours): # verifica daca exista
		#var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		#var content = file.get_as_text() #ia ca string
		#file.close()
		#var result = JSON.parse_string(content) #transforma in dictionar
		#if result:
			#data_existenta = result #egaleaza ce era cu noul dictionar din functie
	#else:
		#data_existenta = {}
	#data_existenta["channel"] = valoare #atribuie dictionarului cheia pe care o vreau
	#channel_exists = valoare
	#var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	#file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	#file.close()
	#
#func adauga_parola(valoare: String):
	#var data_existenta = {}
	#if FileAccess.file_exists(path_hours):
		#var file = FileAccess.open(path_hours, FileAccess.READ)
		#var content = file.get_as_text()
		#file.close()
		#var result = JSON.parse_string(content)
		#if result:
			#data_existenta = result
	#else:
		#data_existenta = {}
	#data_existenta["parola"] = valoare
	#parola = valoare
	#var file = FileAccess.open(path_hours, FileAccess.WRITE) 
	#file.store_string(JSON.stringify(data_existenta, "\t")) 
	#file.close()
#
func adauga_code(valoare: String):
	var data_existenta = {}
	var key = Globals.get_secure_key()
	if FileAccess.file_exists(path_hours):
		var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result:
			data_existenta = result
	else:
		data_existenta = {}
	data_existenta["code"] = valoare
	code = valoare
	var file = FileAccess.open_encrypted(path_hours, FileAccess.WRITE, key) 
	file.store_string(JSON.stringify(data_existenta, "\t")) 
	file.close()

func adauga_level(valoare: String):
	var data_existenta = {}
	var key = Globals.get_secure_key()
	if FileAccess.file_exists(path_hours):
		var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result:
			data_existenta = result
	else:
		data_existenta = {}
	data_existenta["level"] = valoare
	level = valoare
	var file = FileAccess.open_encrypted(path_hours, FileAccess.WRITE, key) 
	file.store_string(JSON.stringify(data_existenta, "\t")) 
	file.close()
#
#func adauga_codep(valoare: String):
	#var data_existenta = {}
	#if FileAccess.file_exists(path_hours):
		#var file = FileAccess.open(path_hours, FileAccess.READ)
		#var content = file.get_as_text()
		#file.close()
		#var result = JSON.parse_string(content)
		#if result:
			#data_existenta = result
	#else:
		#data_existenta = {}
	#data_existenta["codep"] = valoare
	#codep = valoare
	#var file = FileAccess.open(path_hours, FileAccess.WRITE) 
	#file.store_string(JSON.stringify(data_existenta, "\t")) 
	#file.close()
	#
	#
#func adauga_scor(valoare: int):
	#var data_existenta = {}
	#if FileAccess.file_exists(path_hours): # verifica daca exista
		#var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		#var content = file.get_as_text() #ia ca string
		#file.close()
		#var result = JSON.parse_string(content) #transforma in dictionar
		#if result:
			#data_existenta = result #egaleaza ce era cu noul dictionar din functie
	#else:
		#data_existenta = {}
		#data_existenta["score"] = valoare #atribuie dictionarului cheia pe care o vreau
	#var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	#file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	#file.close()

func adauga_scor(valoare: int):
	var data_existenta = {}
	var key = Globals.get_secure_key()
	# 1. Citim ce există deja în fișier (dacă fișierul există)
	if FileAccess.file_exists(path_hours):
		var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
		var content = file.get_as_text()
		file.close()
		
		var result = JSON.parse_string(content)
		if result is Dictionary:
			data_existenta = result

	# 2. MODIFICARE / CREARE
	# Indiferent dacă cheia exista sau nu, acum îi setăm valoarea nouă.
	# Dacă exista, va fi suprascrisă. Dacă nu, va fi creată.
	data_existenta["score"] = valoare 
	
	# 3. Salvăm dicționarul actualizat înapoi în fișier
	var file = FileAccess.open_encrypted(path_hours, FileAccess.WRITE, key)
	if file:
		file.store_string(JSON.stringify(data_existenta, "\t"))
		file.close()
		print("Scorul a fost actualizat local la valoarea: ", valoare)

#func scade_scor(valoare: int):
	#var data_existenta = {}
	#if FileAccess.file_exists(path_hours): # verifica daca exista
		#var file = FileAccess.open(path_hours, FileAccess.READ) #citeste
		#var content = file.get_as_text() #ia ca string
		#file.close()
		#var result = JSON.parse_string(content) #transforma in dictionar
		#if result:
			#data_existenta = result #egaleaza ce era cu noul dictionar din functie
	#else:
		#data_existenta = {}
	#if data_existenta.has("score"):
		#data_existenta["score"] -= valoare
		#score -= valoare
	#var file = FileAccess.open(path_hours, FileAccess.WRITE) #salveaza noul dictionar
	#file.store_string(JSON.stringify(data_existenta, "\t")) # pune tab intre ele
	#file.close()
	#
func citeste_personaj():
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return int(valori["personaj"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia

func citeste_level():
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return int(valori["level"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia

func citeste_username():
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return str(valori["username"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia

func citeste_ex_bonus():
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return str(valori["ex_bonus"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia

func citeste_succes():
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return bool(valori["succes"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia

#func citeste_locatie_info():
	#var file = FileAccess.open(path_hours, FileAccess.READ)
	#var content = file.get_as_text()
	#file.close()
	#var valori = JSON.parse_string(content)
	#return str(valori["where"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia
#
func citeste_code():
	if not FileAccess.file_exists(path_hours):
		return ""
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return String(valori["code"])
#
#func citeste_codep():
	#var file = FileAccess.open(path_hours, FileAccess.READ)
	#var content = file.get_as_text()
	#file.close()
	#var valori = JSON.parse_string(content)
	#return String(valori["codep"])
#
#func citeste_email():
	#var file = FileAccess.open(path_hours, FileAccess.READ)
	#var content = file.get_as_text()
	#file.close()
	#var valori = JSON.parse_string(content)
	#return String(valori["email"])
#
func citeste_score():
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(path_hours, FileAccess.READ, key)
	var content = file.get_as_text()
	file.close()
	var valori = JSON.parse_string(content)
	return int(valori["score"])	#citeste efectiv transforma in dictionar si ia valoarea de la cheia aia
	
#func citeste_parola():
	#var file = FileAccess.open(path_hours, FileAccess.READ)
	#var content = file.get_as_text()
	#file.close()
	#var valori = JSON.parse_string(content)
	#return str(valori["parola"])
#
#func citeste_channel():
	#var file = FileAccess.open(path_hours, FileAccess.READ)
	#var content = file.get_as_text()
	#file.close()
	#var valori = JSON.parse_string(content)
	#return str(valori["channel"])
	#
