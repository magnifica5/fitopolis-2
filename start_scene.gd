extends Node2D
@export var channel_id: String = "fitopolis1"
@export var channel_name: String = "Fitopolis Channel"
@export var channel_importance: NotificationChannel.Importance = NotificationChannel.Importance.HIGH
@onready var notification_scheduler = $NotificationScheduler
func _ready() -> void:
	await get_tree().process_frame
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))
	notification_scheduler.initialize()

func _process(delta: float) -> void:
	pass
	
func _on_initialization_completed() -> void:
	if !Globals.avertisment_vizualizat:
		if !notification_scheduler.has_post_notifications_permission():
			notification_scheduler.request_post_notifications_permission()
			Globals.adauga_channel(0)
		else:
			_create_channel()
			Globals.adauga_channel(1)
			
		
func _create_channel():
	var canal = Globals.citeste_channel()
	if int(canal) == 1:
		schedule_all_notifications()
	else:
		var __result = notification_scheduler.create_notification_channel(
			NotificationChannel.new()
					.set_id(channel_id)
					.set_name(channel_name)
					.set_importance(channel_importance))
		schedule_all_notifications()
					
func schedule_all_notifications():
	Globals.load_hours()
	schedule_daily_notification(int(Globals.trezire / 60.0), Globals.trezire % 60)
	schedule_daily_notification(int(Globals.ex / 60.0), Globals.ex % 60)
	schedule_daily_notification(int(Globals.dejun / 60.0), Globals.dejun % 60)
	schedule_daily_notification(int(Globals.pranz / 60.0), Globals.pranz % 60)
	schedule_daily_notification(int(Globals.ex2 / 60.0), Globals.ex2 % 60)
	schedule_daily_notification(int(Globals.cina / 60.0), Globals.cina % 60)
	schedule_daily_notification(int(Globals.somn / 60.0), Globals.somn % 60)

func schedule_daily_notification(hour: int, minute: int):
	var now = Time.get_unix_time_from_system()
	var current_date = Time.get_datetime_dict_from_system()
	var target = {
		"year": current_date.year,
		"month": current_date.month,
		"day": current_date.day,
		"hour": hour,
		"minute": minute,
		"second": 0
	}
	var target_time = Time.get_unix_time_from_datetime_dict(target)
	var delay = target_time - now
	if delay < 0:
		delay += 86400
		
	var data = NotificationData.new()
	data.set_channel_id(channel_id)
	data.set_title("Misiuni noi!")
	data.set_content("E timpul să începi o nouă misiune!")
	data.set_delay(delay)
	notification_scheduler.schedule(data)
	
func _on_texture_button_pressed() -> void:
	$AudioStreamPlayer.play()
	if !Globals.avertisment_vizualizat:
		get_tree().change_scene_to_file("res://setup.tscn")
		HourActivity.save_progress()
	else:
		HourActivity.load_progress()
		var date_now = Time.get_date_string_from_system()
		if HourActivity.date != date_now:
			HourActivity.nr_day += 1
			HourActivity.complete_trezire = 0
			HourActivity.complete_ex = 0
			HourActivity.complete_dejun = 0
			HourActivity.complete_pranz = 0
			HourActivity.complete_ex2 = 0
			HourActivity.complete_cina = 0
			HourActivity.complete_somn = 0
			HourActivity.save_progress()
			get_tree().change_scene_to_file("res://castig_stele.tscn")
		else:
			get_tree().change_scene_to_file("res://login.tscn")
