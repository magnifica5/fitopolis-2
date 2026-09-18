extends TextureRect

@onready var rank_label = $HBoxContainer/RankSlot/Rank
@onready var username_label = $HBoxContainer/RankSlot2/Username
@onready var activities_label = $HBoxContainer/Activities
@onready var rank_image = $HBoxContainer/RankSlot/MedalTextureRect
@onready var avatar_final = $HBoxContainer/RankSlot2/UserTextureButton
@onready var highlight_panel: PanelContainer = $HighlightPanel
var sprite_sheet := preload("res://assets/animals2.png")
var cols := 7
var rows := 3

var medal_textures: Array[Texture2D] = [
	preload("res://assets/medalie_loc_1_s.svg"),
	preload("res://assets/medalie_loc_2.svg"),
	preload("res://assets/medalie_loc_3.svg"),
	preload("res://assets/medalie_loc_4.svg"),
	preload("res://assets/medalie_loc_5.svg")
]

func setup(rank: int, username: String, activities: int, avatar_number: int):
	if rank >= 1 and rank <= 5:
		rank_image.texture = medal_textures[rank - 1]
		rank_image.show()
		rank_label.hide()
	else:
		rank_image.hide()
		rank_label.text = str(rank)
		rank_label.show()
	username_label.text = username
	activities_label.text = str(activities)
	var sheet_size = sprite_sheet.get_size()
	var cell_size = sheet_size / Vector2(cols, rows)
	var row = int(avatar_number / cols)
	var col = avatar_number % cols
	var atlas = AtlasTexture.new()
	atlas.atlas = sprite_sheet
	atlas.region = Rect2(Vector2(col, row) * cell_size, cell_size)
	avatar_final.texture_normal = atlas
	avatar_final.texture_pressed = atlas
	avatar_final.texture_hover = atlas
	avatar_final.texture_focused = atlas
	avatar_final.texture_disabled = atlas

func highlight_current_player() -> void:
	highlight_panel.visible = true
	highlight_panel.modulate.a = 0.0

	var tween := create_tween()
	tween.set_loops(3)

	tween.tween_property(
		highlight_panel,
		"modulate:a",
		1.0,
		0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		highlight_panel,
		"modulate:a",
		0.35,
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	highlight_panel.visible = false

func _ready() -> void:
	highlight_panel.visible = false
