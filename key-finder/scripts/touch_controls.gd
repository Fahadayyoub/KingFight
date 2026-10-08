extends CanvasLayer

# Native touch buttons allow movement and jumping with separate fingers.
const BUTTON_SIZE := 136
const BUTTON_RADIUS := 66.0

var buttons: Array[TouchScreenButton] = []

func _ready() -> void:
	layer = 10
	if not DisplayServer.is_touchscreen_available() and not OS.has_feature("mobile") and not (OS.is_debug_build() and OS.has_feature("macos")):
		return
	make_button("Left", "ui_left", "<")
	make_button("Right", "ui_right", ">")
	make_button("Jump", "ui_accept", "JUMP")
	get_viewport().size_changed.connect(layout_buttons)
	Settings.controls_changed.connect(layout_buttons)
	layout_buttons()

func make_button(button_name: String, action: String, caption: String) -> void:
	var button := TouchScreenButton.new()
	button.name = button_name
	button.action = action
	button.passby_press = action != "ui_accept"
	var shape := CircleShape2D.new()
	shape.radius = BUTTON_RADIUS
	button.shape = shape
	button.texture_normal = button_texture(Color(0.08, 0.18, 0.19, 0.75))
	button.texture_pressed = button_texture(Color(0.65, 0.49, 0.24, 0.9))
	add_child(button)
	var label := Label.new()
	label.text = caption
	label.size = Vector2(BUTTON_SIZE, BUTTON_SIZE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", preload("res://fonts/PixelOperator8-Bold.ttf"))
	label.add_theme_font_size_override("font_size", 24 if caption == "JUMP" else 40)
	button.add_child(label)
	buttons.append(button)

func button_texture(color: Color) -> ImageTexture:
	var image := Image.create(BUTTON_SIZE, BUTTON_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y in range(BUTTON_SIZE):
		for x in range(BUTTON_SIZE):
			var distance := Vector2(x - 67.5, y - 67.5).length()
			if distance <= BUTTON_RADIUS:
				image.set_pixel(x, y, Color(0.91, 0.84, 0.65, 0.85) if distance > BUTTON_RADIUS - 3.0 else color)
	return ImageTexture.create_from_image(image)

func layout_buttons() -> void:
	if buttons.size() != 3:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var safe := Rect2(Vector2.ZERO, viewport_size)
	if OS.has_feature("mobile"):
		var screen_safe := DisplayServer.get_display_safe_area()
		var screen_size := Vector2(DisplayServer.screen_get_size())
		if screen_safe.size.x > 0 and screen_safe.size.y > 0 and screen_size.x > 0 and screen_size.y > 0:
			var ratio := viewport_size / screen_size
			safe = Rect2(Vector2(screen_safe.position) * ratio, Vector2(screen_safe.size) * ratio)
	var bottom := safe.end.y - BUTTON_SIZE - 24.0
	if Settings.arrows_on_left:
		buttons[0].position = Vector2(safe.position.x + 24.0, bottom)
		buttons[1].position = Vector2(safe.position.x + BUTTON_SIZE + 40.0, bottom)
		buttons[2].position = Vector2(safe.end.x - BUTTON_SIZE - 24.0, bottom)
	else:
		buttons[2].position = Vector2(safe.position.x + 24.0, bottom)
		buttons[0].position = Vector2(safe.end.x - BUTTON_SIZE * 2 - 40.0, bottom)
		buttons[1].position = Vector2(safe.end.x - BUTTON_SIZE - 24.0, bottom)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# Hiding a TouchScreenButton releases its held touch action.
		for button in buttons:
			button.hide()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		for button in buttons:
			button.show()
