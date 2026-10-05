extends Control

const GAME_SCENE := preload("res://scenes/game.tscn")
const KNIGHT := preload("res://sprites/knight.png")
const FONT := preload("res://fonts/PixelOperator8-Bold.ttf")
const BASE_SIZE := Vector2(960, 540)

var elapsed := 0.0
var starting := false
var canvas: Control
var start_button: Button
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
	var mobile := DisplayServer.is_touchscreen_available() or OS.has_feature("mobile") or (OS.is_debug_build() and OS.has_feature("macos"))
	add_label("Touch arrows to move. Tap JUMP to leap." if mobile else "ARROW KEYS  Move     SPACE  Jump", Vector2(0, 424), 14, Color("a9c8b2"))
	add_label("Tap Start to begin" if mobile else "Press Enter or click Start", Vector2(0, 456), 12, Color("769d8b"))

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


func start_game() -> void:
	if starting:
		return
	starting = true
	Progress.reset()
	start_button.disabled = true
	click_sound.play()
	var transition := create_tween()
	transition.tween_property(fade, "modulate:a", 1.0, 0.4)
	await transition.finished
	var error := get_tree().change_scene_to_packed(GAME_SCENE)
	if error != OK:
		starting = false
		start_button.disabled = false
		fade.modulate.a = 0.0
		start_button.grab_focus()
		push_error("Could not open the game: %s" % error)
