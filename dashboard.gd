extends Control
@onready var home = $HBoxContainer/Panel/VBoxContainer/TextureButton
@onready var settings = $HBoxContainer/Panel/VBoxContainer/TextureButton2
@onready var reports = $HBoxContainer/Panel/VBoxContainer/TextureButton3
@onready var schedule = $HBoxContainer/Panel/VBoxContainer/TextureButton4
@onready var tabs = $HBoxContainer/MarginContainer/TabContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_home_pressed() -> void:
	tabs.current_tab = 0
	
func _on_settings_pressed() -> void:
	tabs.current_tab = 1

func _on_reports_pressed() -> void:
	tabs.current_tab = 2

func _on_schedule_pressed() -> void:
	tabs.current_tab = 3
