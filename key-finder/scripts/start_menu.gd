extends Control

const KNIGHT := preload("res://sprites/knight.png")
const FONT := preload("res://fonts/PixelOperator8-Bold.ttf")
const BASE_SIZE := Vector2(960, 540)

var elapsed := 0.0
var starting := false
var canvas: Control
var start_button: Button
var settings_button: Button
var settings_overlay: Control
var music_toggle: CheckButton
var layout_option: OptionButton
var level_code_input: LineEdit
var code_message: Label
var code_button: Button
var fade: ColorRect
var click_sound: AudioStreamPlayer


func _ready() -> void:
	canvas = Control.new()
	canvas.size = BASE_SIZE
	add_child(canvas)
	add_label("A LITTLE KNIGHT. A BIG ADVENTURE.", Vector2(0, 76), 14, Color("93baa2"))
	add_label("KEY FINDER", Vector2(0, 112), 48, Color("ffe5a0"))
	add_label("Collect coins. Dodge slimes. Find your way.", Vector2(0, 180), 14, Color("c7dbce"))

	start_button = Button.new()
	start_button.text = "START GAME"
	start_button.position = Vector2(350, 330)
	start_button.size = Vector2(260, 62)
	start_button.add_theme_font_override("font", FONT)
	start_button.add_theme_font_size_override("font_size", 22)
	start_button.add_theme_color_override("font_color", Color("172e2b"))
	start_button.add_theme_color_override("font_hover_color", Color("172e2b"))
	start_button.add_theme_color_override("font_pressed_color", Color("172e2b"))
	start_button.add_theme_stylebox_override("normal", button_style(Color("edbd68")))
	start_button.add_theme_stylebox_override("hover", button_style(Color("ffe4a0")))
	start_button.add_theme_stylebox_override("pressed", button_style(Color("c7954c")))
	var focus_style := StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.border_color = Color("fff2ca")
	focus_style.set_border_width_all(2)
	focus_style.set_expand_margin_all(5)
	start_button.add_theme_stylebox_override("focus", focus_style)
	canvas.add_child(start_button)
	start_button.pressed.connect(start_game)
	start_button.grab_focus()
	settings_button = menu_button("SETTINGS", 16)
	settings_button.position = Vector2(390, 405)
	settings_button.size = Vector2(180, 38)
	canvas.add_child(settings_button)
	settings_button.pressed.connect(open_settings)
	var mobile := DisplayServer.is_touchscreen_available() or OS.has_feature("mobile") or (OS.is_debug_build() and OS.has_feature("macos"))
	add_label("Touch arrows to move. Tap JUMP to leap." if mobile else "ARROW KEYS  Move     SPACE  Jump", Vector2(0, 463), 14, Color("a9c8b2"))
	add_label("GAME OVER - Start to try again" if Progress.lives == 0 else ("Tap Start to begin" if mobile else "Press Enter or click Start"), Vector2(0, 495), 12, Color("769d8b"))

	build_settings()
	click_sound = AudioStreamPlayer.new()
	click_sound.stream = preload("res://sounds/power_up.wav")
	click_sound.bus = &"SFX"
	add_child(click_sound)
	fade = ColorRect.new()
	fade.color = Color("0c1c25")
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fade)
	resized.connect(layout_canvas)
	layout_canvas()
	create_tween().tween_property(fade, "modulate:a", 0.0, 0.65)
	canvas.modulate.a = 0.0
	create_tween().tween_property(canvas, "modulate:a", 1.0, 0.85)


func add_label(text: String, at: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = at
	label.size.x = BASE_SIZE.x
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	canvas.add_child(label)


func button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("9b693e")
	style.border_width_bottom = 5
	style.set_corner_radius_all(6)
	return style


func layout_canvas() -> void:
	var factor := minf(size.x / BASE_SIZE.x, size.y / BASE_SIZE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - BASE_SIZE * factor) / 2.0


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("0c1c25"))
	if not is_instance_valid(canvas):
		return
	draw_set_transform(canvas.position, 0.0, canvas.scale)
	# Layered mountain silhouettes and drifting fireflies.
	draw_circle(Vector2(780, 108), 43, Color("26474a"))
	draw_circle(Vector2(770, 99), 32, Color("9aaf82"))
	for layer in range(3):
		var points := PackedVector2Array([Vector2(-100, 560)])
		for step in range(13):
			var x := float(step * 100 - 100)
			var y := 285.0 + layer * 65.0 + sin(step * 1.7 + layer * 2.0) * 55.0
			points.append(Vector2(x, y))
		points.append(Vector2(1100, 560))
		draw_colored_polygon(points, [Color("142f38"), Color("1c4143"), Color("24534a")][layer])
	for index in range(28):
		var x := fposmod(index * 137.0 + elapsed * (3.0 + index % 4), 960.0)
		var y := 35.0 + fposmod(index * 71.0, 460.0) + sin(elapsed + index) * 9.0
		var glow := Color("e8d793")
		glow.a = 0.2 + (sin(elapsed * 1.5 + index) + 1.0) * 0.2
		draw_rect(Rect2(Vector2(x, y), Vector2(3, 3)), glow)
	# A small floating grassy island beneath the animated knight.
	var bob := sin(elapsed * 2.0) * 4.0
	draw_style_box(button_style(Color("55463c")), Rect2(410, 297, 140, 17))
	draw_rect(Rect2(406, 291, 148, 7), Color("83ad65"))
	draw_texture_rect_region(KNIGHT, Rect2(432, 206 + bob, 96, 96), Rect2(int(elapsed * 8.0) % 4 * 32, 0, 32, 32))
	draw_set_transform(Vector2.ZERO)


func menu_button(caption: String, font_size := 16) -> Button:
	var button := Button.new()
	button.text = caption
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size", font_size)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, Color("172e2b"))
	button.add_theme_stylebox_override("normal", button_style(Color("edbd68")))
	button.add_theme_stylebox_override("hover", button_style(Color("ffe4a0")))
	button.add_theme_stylebox_override("pressed", button_style(Color("c7954c")))
	return button


func settings_label(text: String, font_size := 14) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("c7dbce"))
	return label


func build_settings() -> void:
	settings_overlay = Control.new()
	settings_overlay.size = BASE_SIZE
	canvas.add_child(settings_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.06, 0.08, 0.9)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_overlay.add_child(dim)
	var panel := PanelContainer.new()
	panel.position = Vector2(190, 30)
	panel.size = Vector2(580, 480)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("173b3b")
	style.border_color = Color("93baa2")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 26
	style.content_margin_right = 26
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", style)
	settings_overlay.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	var title := settings_label("SETTINGS", 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	music_toggle = CheckButton.new()
	music_toggle.text = "Music"
	music_toggle.add_theme_font_override("font", FONT)
	music_toggle.add_theme_font_size_override("font_size", 16)
	music_toggle.custom_minimum_size.y = 42
	column.add_child(music_toggle)
	music_toggle.toggled.connect(Settings.set_music_enabled)
	Settings.music_changed.connect(music_toggle.set_pressed_no_signal)
	music_toggle.set_pressed_no_signal(Settings.music_enabled)
	column.add_child(settings_label("Touch button positions"))
	layout_option = OptionButton.new()
	layout_option.add_item("JUMP left / arrows right")
	layout_option.add_item("Arrows left / JUMP right")
	layout_option.add_theme_font_override("font", FONT)
	layout_option.add_theme_font_size_override("font_size", 14)
	layout_option.custom_minimum_size.y = 40
	column.add_child(layout_option)
	layout_option.item_selected.connect(func(index: int): Settings.set_arrows_on_left(index == 1))
	column.add_child(settings_label("Jump straight to a level"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	column.add_child(row)
	level_code_input = LineEdit.new()
	level_code_input.placeholder_text = "3 letters + 3 numbers"
	level_code_input.max_length = 24
	level_code_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_code_input.custom_minimum_size.y = 44
	level_code_input.add_theme_font_override("font", FONT)
	level_code_input.add_theme_font_size_override("font_size", 14)
	row.add_child(level_code_input)
	level_code_input.text_submitted.connect(func(_code: String): launch_level_code())
	level_code_input.text_changed.connect(func(_code: String): code_message.text = "")
	code_button = menu_button("GO", 16)
	code_button.custom_minimum_size.x = 90
	row.add_child(code_button)
	code_button.pressed.connect(launch_level_code)
	column.add_child(settings_label("Replay codes appear after each level.", 12))
	code_message = settings_label("", 12)
	code_message.custom_minimum_size.y = 32
	code_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	code_message.add_theme_color_override("font_color", Color("ffb3a0"))
	column.add_child(code_message)
	var back := menu_button("BACK", 16)
	back.custom_minimum_size.y = 42
	column.add_child(back)
	back.pressed.connect(close_settings)
	settings_overlay.hide()


func open_settings() -> void:
	if starting:
		return
	music_toggle.set_pressed_no_signal(Settings.music_enabled)
	layout_option.select(1 if Settings.arrows_on_left else 0)
	settings_overlay.show()
	start_button.disabled = true
	settings_button.disabled = true
	music_toggle.grab_focus()


func close_settings() -> void:
	if starting:
		return
	settings_overlay.hide()
	start_button.disabled = false
	settings_button.disabled = false
	settings_button.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and settings_overlay.visible:
		close_settings()
		get_viewport().set_input_as_handled()


func launch_level_code() -> void:
	if starting:
		return
	var path := Settings.level_scene_for_code(level_code_input.text)
	if path.is_empty():
		code_message.text = "Invalid code. Check your saved replay code."
		level_code_input.grab_focus()
		return
	start_level(path)


func start_game() -> void:
	start_level("res://scenes/level_1.tscn")


func start_level(path: String) -> void:
	if starting:
		return
	starting = true
	Engine.time_scale = 1.0
	Progress.reset()
	start_button.disabled = true
	settings_button.disabled = true
	code_button.disabled = true
	settings_overlay.hide()
	click_sound.play()
	var transition := create_tween()
	transition.tween_property(fade, "modulate:a", 1.0, 0.4)
	await transition.finished
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		starting = false
		start_button.disabled = false
		settings_button.disabled = false
		code_button.disabled = false
		fade.modulate.a = 0.0
		open_settings()
		code_message.text = "Could not open this level. Please try again."
		push_error("Could not open the game: %s" % error)
