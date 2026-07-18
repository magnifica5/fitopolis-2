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
	if Engine.has_singleton("LocalNotification"):
		LocalNotification.init()
		LocalNotification.requestPermission()
		LocalNotification.connect("on_permission_request_completed", Callable(self, "_on_permissions_granted"))
	
	# Citim tipul de cont o singură dată la început
	_update_account_type()
	setup_realtime_listener()

func _on_permissions_granted():
	print("avem permisiune")
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
			# OPTIMIZARE: Folosim direct 'new_record' primite prin WebSocket
			# Nu mai facem 'await task.completed' (cerere la DB), economisim ~1-2 secunde
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
	
	var hour = int(parts[0])
	var minute = int(parts[1])
	
	LocalNotification.cancel(id)
	LocalNotification.showDaily(title, message, hour, minute, id)
	print("Notificare ID ", id, " setată pentru ora: ", hour, ":", minute)
