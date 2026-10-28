extends CanvasLayer

# Textul afisat in timpul trecerii de la Start la urmatoarea scena.
const MESSAGE := "Se încarcă..."

func _ready() -> void:
	name = "StartLoadingOverlay"
	layer = 1000
	var background := ColorRect.new()
	background.color = Color("344d39")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(background)
	if DisplayServer.get_name() != "headless":
		var picture := get_viewport().get_texture().get_image()
		if picture != null and not picture.is_empty():
			var snapshot := TextureRect.new()
			snapshot.texture = ImageTexture.create_from_image(picture)
			snapshot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			snapshot.stretch_mode = TextureRect.STRETCH_SCALE
			snapshot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			snapshot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			background.add_child(snapshot)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(dim)
	var label := Label.new()
	label.text = MESSAGE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	background.add_child(label)

func wait_until_drawn() -> void:
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw

func finish_when_scene_ready() -> void:
	await get_tree().scene_changed
	await wait_until_drawn()
	queue_free()
