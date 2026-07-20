## Cod optimizat pentru a reduce latența și a preveni refresh-ul inutil
#extends Node
#var path = "user://start.save"
#var realtime_client : RealtimeClient
#var realtime_channel : RealtimeChannel
#var content
#
## Lista coloanelor care reprezintă orele activităților
#const TIME_COLUMNS = [
	#"trezire", 
	#"ex1", 
	#"masa_dimineata", 
	#"masa_pranz", 
	#"ex2", 
	#"masa_seara", 
	#"culcare",
	#"verificare"
#]
#
#func _ready() -> void:
	##request_battery_optimization()
	#if Engine.has_singleton("LocalNotification"):
		#LocalNotification.init()
		#LocalNotification.requestPermission()
		#LocalNotification.connect("on_permission_request_completed", Callable(self, "_on_permissions_granted"))
	#
	## Citim tipul de cont o singură dată la început
	#_update_account_type()
	#setup_realtime_listener()
#
#func _on_permissions_granted():
	#print("avem permisiune")
	## La prima pornire, facem un fetch inițial pentru a seta notificările
	#_initial_fetch()
#
#func _update_account_type():
	#if FileAccess.file_exists(path):
		#var file = FileAccess.open(path, FileAccess.READ)
		#content = file.get_as_text()
		#file.close()
#
#func _initial_fetch():
	#Globals.code = Globals.citeste_code()
	#var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	#var task = Supabase.database.query(query)
	#var result = await task.completed
	#if result.error == null and result.data.size() > 0:
		#set_notifications_from_data(result.data[0])
#
#func setup_realtime_listener():
	#realtime_client = Supabase.realtime.client()
	#realtime_client.connected.connect(on_realtime_connected)
	#realtime_client.connect_client()
#
#func on_realtime_connected():
	#realtime_channel = realtime_client.channel("public", "children")
	#realtime_channel.on("update", Callable(self, "_on_child_data_updated"))
	#realtime_channel.subscribe()
#
#func _on_child_data_updated(old_record, new_record, _channel):
	#Globals.code = Globals.citeste_code()
	#if new_record.connection_code == Globals.code:
		#var time_changed = false
		#for col in TIME_COLUMNS:
			#if old_record.has(col) and new_record.has(col):
				#if old_record[col] != new_record[col]:
					#time_changed = true
					#break
		#
		#if time_changed:
			#print("Schimbare detectată la ore. Actualizăm notificările INSTANT.")
			## OPTIMIZARE: Folosim direct 'new_record' primite prin WebSocket
			## Nu mai facem 'await task.completed' (cerere la DB), economisim ~1-2 secunde
			#set_notifications_from_data(new_record)
#
## Funcție centralizată pentru setarea notificărilor
#func set_notifications_from_data(data: Dictionary):
	#_update_account_type() # Ne asigurăm că avem tipul de cont actualizat
	#
	#if content == "copil\n":
		#_setup_notif(data.trezire, 100, "Activitate Noua", "Buna dimineata! Este timpul sa te trezesti!")
		#_setup_notif(data.ex1, 101, "Activitate Noua", "Esti pregatit? Este timpul pentru putina miscare!")
		#_setup_notif(data.masa_dimineata, 102, "Activitate Noua", "Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de dimineata.")
		#_setup_notif(data.masa_pranz, 103, "Activitate Noua", "Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de pranz.")
		#_setup_notif(data.ex2, 104, "Activitate Noua", "Esti pregatit? Este timpul pentru putina miscare!")
		#_setup_notif(data.masa_seara, 105, "Activitate Noua", "Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de seara.")
		#_setup_notif(data.culcare, 106, "Activitate Noua", "Noapte buna! Este timpul să te pregătești de somn.")
	#elif content == "parinte\n":
		#_setup_notif(data.verificare, 107, "Activitate Noua", "Este timpul pentru verificarea activităților.")
#
## Funcție helper pentru a evita repetarea codului de split și setare
#func _setup_notif(time_str: String, id: int, title: String, message: String):
	#if time_str == "" or time_str == null: return
	#
	#var parts = time_str.split(":")
	#if parts.size() < 2: return
	#
	#var target_hour = int(parts[0])
	#var target_minute = int(parts[1])
	#
	## 1. Luăm ora locală exactă a telefonului (ce scrie pe ecran)
	#var now = Time.get_time_dict_from_system()
	#
	## 2. Convertim totul în secunde de la începutul zilei
	#var now_seconds = (now.hour * 3600) + (now.minute * 60) + now.second
	#var target_seconds = (target_hour * 3600) + (target_minute * 60)
	#
	## 3. Calculăm delay-ul
	#var delay = target_seconds - now_seconds
	#
	## 4. Dacă ora a trecut deja astăzi, programăm pentru mâine
	#if delay <= 0:
		#delay += 86400 # adăugăm 24 ore în secunde
	#
	#if Engine.has_singleton("LocalNotification"):
		#var ln = Engine.get_singleton("LocalNotification")
		#ln.cancel(id)
		## Folosim 'show' în loc de 'showDaily' pentru a controla noi timpul exact
		## API: show(mesaj, titlu, secunde_delay, id)
		#ln.show(message, title, delay, id)
		#print("Programat: ", title, " peste ", delay, " secunde (Ora locală)")
# Cod optimizat pentru a reduce latența și a preveni refresh-ul inutil
extends Node

var path = "user://start.save"
var realtime_client : RealtimeClient
var realtime_channel : RealtimeChannel
var content

# Lista coloanelor care reprezintă orele activităților
const TIME_COLUMNS = [
	"trezire", 
	"ex1", 
	"masa_dimineata", 
	"masa_pranz", 
	"ex2", 
	"masa_seara", 
	"culcare",
	"verificare"
]

func _ready() -> void:
	# 1. Cerem permisiunea pentru notificări (Android 13+)
	if Engine.has_singleton("LocalNotification"):
		LocalNotification.init()
		LocalNotification.requestPermission()
		LocalNotification.connect("on_permission_request_completed", Callable(self, "_on_permissions_granted"))
	
	if !FileAccess.file_exists(path):
		request_battery_optimization()
	
	# Citim tipul de cont o singură dată la început
	_update_account_type()
	setup_realtime_listener()

func request_battery_optimization():
	if OS.get_name() != "Android":
		return
	# Folosim JNI pentru a accesa API-ul Android
	var os = OS
	# Verificăm dacă permisiunea a fost deja acordată
	# Deoarece verificarea directă din GDScript e complexă, 
	# vom deschide setările aplicației unde utilizatorul poate debifa optimizarea.
	# O metodă mai directă necesită un plugin custom de Android.
	
	# Metoda 1: Deschidem setările aplicației (Cel mai sigur din GDScript pur)
	print("Deschidem setările pentru ca utilizatorul să oprească optimizarea bateriei.")
	# OS.shell_open("package:" + ProjectSettings.get_setting("application/config/name"))
	
	# Metoda 2: Dacă folosești un plugin care expune Intent-uri, sau dacă vrei să folosești JNI
	# În lipsa unui plugin specific pentru baterie, cea mai bună abordare este să afișezi
	# un dialog în joc (ConfirmationDialog) care explică utilizatorului CE trebuie să facă,
	# apoi să deschizi setările aplicației.
	_show_battery_explanation_dialog()

func _show_battery_explanation_dialog():
	var dialog = AcceptDialog.new()
	dialog.title = ""
	dialog.dialog_text = "Pentru ca notificările să ajungă la timp, te rugăm să dezactivezi optimizarea bateriei. În ecranul următor apasă pe Baterie/Battery iar mai apoi pe Nerestrictionat/Unrestricted"
	
	# 1. Accesăm Label-ul intern pentru a-i mări fontul
	var label = dialog.get_label()
	label.add_theme_font_size_override("font_size", 40) # Setează dimensiunea dorită (ex: 24)
	
	# 2. Opțional: Putem mări și textul de pe butonul OK
	var ok_button = dialog.get_ok_button()
	ok_button.add_theme_font_size_override("font_size", 40)
	
	dialog.ok_button_text = "Deschide Setările"
	dialog.min_size = Vector2i(700, 500) # Am mărit puțin fereastra pentru a cuprinde textul mai mare
	dialog.dialog_autowrap = true
	
	dialog.confirmed.connect(self._on_battery_dialog_confirmed)
	add_child(dialog)
	dialog.popup_centered()



func _on_battery_dialog_confirmed():
	if Engine.has_singleton("LocalNotification"):
		var ln = Engine.get_singleton("LocalNotification")
		# Pluginul kyoz are o funcție utilă pentru a deschide setările aplicației
		ln.openAppSetting()
	else:
		# Fallback
		OS.shell_open("app-settings:")

func _on_permissions_granted():
	print("Avem permisiune pentru notificări")
	# La prima pornire, facem un fetch inițial pentru a seta notificările
	_initial_fetch()

func _update_account_type():
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		content = file.get_as_text()
		file.close()

func _initial_fetch():
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		set_notifications_from_data(result.data[0])

func setup_realtime_listener():
	realtime_client = Supabase.realtime.client()
	realtime_client.connected.connect(on_realtime_connected)
	realtime_client.connect_client()

func on_realtime_connected():
	realtime_channel = realtime_client.channel("public", "children")
	realtime_channel.on("update", Callable(self, "_on_child_data_updated"))
	realtime_channel.subscribe()

func _on_child_data_updated(old_record, new_record, _channel):
	Globals.code = Globals.citeste_code()
	if new_record.connection_code == Globals.code:
		var time_changed = false
		for col in TIME_COLUMNS:
			if old_record.has(col) and new_record.has(col):
				if old_record[col] != new_record[col]:
					time_changed = true
					break
		
		if time_changed:
			print("Schimbare detectată la ore. Actualizăm notificările INSTANT.")
			set_notifications_from_data(new_record)

# Funcție centralizată pentru setarea notificărilor
func set_notifications_from_data(data: Dictionary):
	_update_account_type() # Ne asigurăm că avem tipul de cont actualizat
	
	if content == "copil\n":
		_setup_notif(data.trezire, 100, "Activitate Noua", "Buna dimineata! Este timpul sa te trezesti!")
		_setup_notif(data.ex1, 101, "Activitate Noua", "Esti pregatit? Este timpul pentru putina miscare!")
		_setup_notif(data.masa_dimineata, 102, "Activitate Noua", "Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de dimineata.")
		_setup_notif(data.masa_pranz, 103, "Activitate Noua", "Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de pranz.")
		_setup_notif(data.ex2, 104, "Activitate Noua", "Esti pregatit? Este timpul pentru putina miscare!")
		_setup_notif(data.masa_seara, 105, "Activitate Noua", "Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de seara.")
		_setup_notif(data.culcare, 106, "Activitate Noua", "Noapte buna! Este timpul să te pregătești de somn.")
	elif content == "parinte\n":
		_setup_notif(data.verificare, 107, "Activitate Noua", "Este timpul pentru verificarea activităților.")

# Funcție helper pentru a evita repetarea codului de split și setare
func _setup_notif(time_str: String, id: int, title: String, message: String):
	if time_str == "" or time_str == null: return
	
	var parts = time_str.split(":")
	if parts.size() < 2: return
	
	var target_hour = int(parts[0])
	var target_minute = int(parts[1])
	
	# 1. Luăm ora locală exactă a telefonului (ce scrie pe ecran)
	var now = Time.get_time_dict_from_system()
	
	# 2. Convertim totul în secunde de la începutul zilei
	var now_seconds = (now.hour * 3600) + (now.minute * 60) + now.second
	var target_seconds = (target_hour * 3600) + (target_minute * 60)
	
	# 3. Calculăm delay-ul
	var delay = target_seconds - now_seconds
	
	# 4. Dacă ora a trecut deja astăzi, programăm pentru mâine
	if delay <= 0:
		delay += 86400 # adăugăm 24 ore în secunde
	
	if Engine.has_singleton("LocalNotification"):
		var ln = Engine.get_singleton("LocalNotification")
		ln.cancel(id)
		# Folosim 'show' în loc de 'showDaily' pentru a controla noi timpul exact
		# API: show(mesaj, titlu, secunde_delay, id)
		ln.show(message, title, delay, id)
		print("Programat: ", title, " peste ", delay, " secunde (Ora locală)")
