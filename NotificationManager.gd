# pentru a diferentia notificarile bazat pe ce tip de cont este + orice alta diferenta gasesti maine foloseste
# ce ai salvat la inceput in fisierul acela gen copil/parinte, cel de la start
# recomandat - prima oara se decide clar ce tip de cont este, copil/parinte dupa care se seteaza orele
# practic, prima oara parintii autentifica copiii pe telefoanele lor, dupa care introduc orele
extends Node

var realtime_client : RealtimeClient
var realtime_channel : RealtimeChannel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.has_singleton("LocalNotification"):
		LocalNotification.init()
		LocalNotification.requestPermission()
		LocalNotification.connect("on_permission_request_completed", Callable(self, "_on_permissions_granted"))
	setup_realtime_listener()

func _on_permissions_granted():
	print("avem permisiune")
	refresh_notifications()

func setup_realtime_listener():
	# 1. Obținem un client de Realtime de la managerul Supabase
	realtime_client = Supabase.realtime.client()
	
	# 2. Ne conectăm la serverul de Realtime (WebSocket)
	realtime_client.connected.connect(on_realtime_connected)
	realtime_client.connect_client()
	print("Se inițiază conexiunea la Realtime...")

func on_realtime_connected():
	print("Conectat la serverul Realtime.")
	# 3. Creăm canalul prin intermediul clientului conectat
	# Parametrii: schema ("public"), table ("children"), col_value (opțional)
	realtime_channel = realtime_client.channel("public", "children")
	
	# 4. Mapăm evenimentul 'update' (atenție: este la singular în plugin)
	# Semnalul 'update' trimite: (old_record, new_record, channel)
	realtime_channel.on("update", Callable(self, "_on_child_data_updated"))
	
	# 5. Ne abonăm efectiv la canal
	realtime_channel.subscribe()
	print("Suntem abonați la tabela 'children'.")

# Funcția trebuie să accepte 3 argumente conform semnalului 'update' din plugin
func _on_child_data_updated(old_record, new_record, _channel):
	# Verificăm dacă datele aparțin utilizatorului curent
	if new_record.username == Globals.username:
		print("Datele copilului au fost modificate.")
		refresh_notifications()

func refresh_notifications():
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("username", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		# ----------- notificare trezire ------------------
		var ora_trezire = data.trezire
		var parts = ora_trezire.split(":")
		var hour = int(parts[0])
		var minute = int(parts[1])
		LocalNotification.cancel(100)
		LocalNotification.showDaily(
			"Activitate Noua",
			"Buna dimineata! Este timpul sa te trezesti!",
			hour,
			minute,
			100
		)
		print("Notificare setată pentru ora: ", hour, ":", minute)
		# --------------- notificare ex1 --------------
		var ora_ex1 = data.ex1
		var parts1 = ora_ex1.split(":")
		var hour1 = int(parts1[0])
		var minute1 = int(parts1[1])
		LocalNotification.cancel(101)
		LocalNotification.showDaily(
			"Activitate Noua",
			"Esti pregatit? Este timpul pentru putina miscare!",
			hour1,
			minute1,
			101
		)
		print("Notificare setată pentru ora: ", hour, ":", minute)
		# ------------ notificare masa_dimineata ----------------
		var ora_mdimineata = data.masa_dimineata
		var parts2 = ora_mdimineata.split(":")
		var hour2 = int(parts2[0])
		var minute2 = int(parts2[1])
		LocalNotification.cancel(102)
		LocalNotification.showDaily(
			"Activitate Noua",
			"Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de dimineata.",
			hour2,
			minute2,
			102
		)
		print("Notificare setată pentru ora: ", hour, ":", minute)
		# --------------- notificare masa_pranz -----------------------
		var ora_mpranz = data.masa_pranz
		var parts3 = ora_mpranz.split(":")
		var hour3 = int(parts3[0])
		var minute3 = int(parts3[1])
		LocalNotification.cancel(103)
		LocalNotification.showDaily(
			"Activitate Noua",
			"Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de pranz.",
			hour3,
			minute3,
			103
		)
		print("Notificare setată pentru ora: ", hour, ":", minute)
		# --------------- notificare ex2 ------------------
		var ora_ex2 = data.ex2
		var parts4 = ora_ex2.split(":")
		var hour4 = int(parts4[0])
		var minute4 = int(parts4[1])
		LocalNotification.cancel(104)
		LocalNotification.showDaily(
			"Activitate Noua",
			"Esti pregatit? Este timpul pentru putina miscare!",
			hour4,
			minute4,
			104
		)
		print("Notificare setată pentru ora: ", hour, ":", minute)
		# ------------- notificare masa_seara --------------
		var ora_mseara = data.masa_seara
		var parts5 = ora_mseara.split(":")
		var hour5 = int(parts5[0])
		var minute5 = int(parts5[1])
		LocalNotification.cancel(105)
		LocalNotification.showDaily(
			"Activitate Noua",
			"Orice erou are nevoie sa-si incarce bateriile! Este timpul pentru masa de seara.",
			hour5,
			minute5,
			105
		)
		print("Notificare setată pentru ora: ", hour, ":", minute)
		# -------------- notificare culcare ---------------
		var ora_culcare = data.culcare
		var parts6 = ora_culcare.split(":")
		var hour6 = int(parts6[0])
		var minute6 = int(parts6[1])
		LocalNotification.cancel(106)
		LocalNotification.showDaily(
			"Activitate Noua",
			"Noapte buna! Este timpul să te pregătești de somn.",
			hour6,
			minute6,
			106
		)
		print("Notificare setată pentru ora: ", hour, ":", minute)
		# --------- notificare verificare --------
		var ora_verificare = data.verificare
		var parts7 = ora_verificare.split(":")
		var hour7 = int(parts7[0])
		var minute7 = int(parts7[1])
		LocalNotification.cancel(107)
		LocalNotification.showDaily(
			"Activitate Noua",
			"Noapte buna! Este timpul să te pregătești de somn.",
			hour7,
			minute7,
			107
		)
		print("Notificare setată pentru ora: ", hour, ":", minute)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
