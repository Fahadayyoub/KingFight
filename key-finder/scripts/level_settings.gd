extends CanvasLayer

const FONT := preload("res://fonts/PixelOperator8-Bold.ttf")
const PANEL_SIZE := Vector2(420, 260)

var ui: Control
var settings_button: Button
var overlay: Control
var panel: Panel
var music_toggle: CheckButton
var home_button: Button
var was_paused := false
var leaving := false
var hidden_touch_controls: Array[Node] = []


func _ready() -> void:
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	settings_button = make_button("SETTINGS", 12)
	settings_button.focus_mode = Control.FOCUS_NONE
	settings_button.size = Vector2(136, 44)
	ui.add_child(settings_button)
	settings_button.pressed.connect(open_settings)

	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.06, 0.08, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	dim.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			close_settings()
	)
	panel = Panel.new()
	panel.size = PANEL_SIZE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("173b3b")
	style.border_color = Color("93baa2")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)
	var title := Label.new()
	title.text = "SETTINGS"
	title.position = Vector2(24, 24)
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("ffe5a0"))
	panel.add_child(title)
	var close := make_button("X", 16)
	close.position = Vector2(342, 16)
	close.size = Vector2(54, 36)
	panel.add_child(close)
	close.pressed.connect(close_settings)
	music_toggle = CheckButton.new()
	music_toggle.text = "Music"
	music_toggle.position = Vector2(24, 82)
	music_toggle.size = Vector2(372, 48)
	music_toggle.add_theme_font_override("font", FONT)
	music_toggle.add_theme_font_size_override("font_size", 18)
	panel.add_child(music_toggle)
	music_toggle.toggled.connect(Settings.set_music_enabled)
	Settings.music_changed.connect(music_toggle.set_pressed_no_signal)
	music_toggle.set_pressed_no_signal(Settings.music_enabled)
	home_button = make_button("HOME SCREEN", 18)
	home_button.position = Vector2(24, 160)
	home_button.size = Vector2(372, 52)
	panel.add_child(home_button)
	home_button.pressed.connect(go_home)
	overlay.hide()
	get_viewport().size_changed.connect(layout_ui)
	layout_ui()


func make_button(caption: String, font_size: int) -> Button:
	var button := Button.new()
	button.text = caption
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size", font_size)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, Color("172e2b"))
	for state in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("ffe4a0") if state == "hover" else Color("c7954c") if state == "pressed" else Color("edbd68")
		style.border_color = Color("9b693e")
		style.border_width_bottom = 4
		style.set_corner_radius_all(6)
		button.add_theme_stylebox_override(state, style)
	return button


func layout_ui() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var safe := Rect2(Vector2.ZERO, viewport_size)
	if OS.has_feature("mobile"):
		var screen_safe := DisplayServer.get_display_safe_area()
		var screen_size := Vector2(DisplayServer.screen_get_size())
		if screen_safe.size.x > 0 and screen_safe.size.y > 0 and screen_size.x > 0 and screen_size.y > 0:
			var ratio := viewport_size / screen_size
			safe = Rect2(Vector2(screen_safe.position) * ratio, Vector2(screen_safe.size) * ratio)
	settings_button.position = Vector2(safe.end.x - settings_button.size.x - 24, safe.position.y + 14)
	var factor := minf(1.0, minf(safe.size.x / 960.0, safe.size.y / 540.0))
	panel.scale = Vector2.ONE * factor
	panel.position = safe.position + (safe.size - PANEL_SIZE * factor) / 2.0


func open_settings() -> void:
	if overlay.visible or leaving or Progress.dying:
		return
	was_paused = get_tree().paused
	music_toggle.set_pressed_no_signal(Settings.music_enabled)
	# Hide touch buttons to release held movement and block touches behind the popup.
	hidden_touch_controls.clear()
	for node in get_tree().current_scene.find_children("*", "TouchScreenButton", true, false):
		if node.visible:
			hidden_touch_controls.append(node)
			node.hide()
	for action in ["ui_left", "ui_right", "ui_accept"]:
		Input.action_release(action)
	overlay.show()
	get_tree().paused = true
	music_toggle.grab_focus()


func close_settings() -> void:
	if not overlay.visible or leaving:
		return
	overlay.hide()
	for action in ["ui_left", "ui_right", "ui_accept"]:
		Input.action_release(action)
	get_tree().paused = was_paused
	for node in hidden_touch_controls:
		if is_instance_valid(node):
			node.show()
	hidden_touch_controls.clear()
	music_toggle.release_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if overlay.visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close_settings()
		get_viewport().set_input_as_handled()


func go_home() -> void:
	if leaving:
		return
	leaving = true
	get_tree().paused = false
	Engine.time_scale = 1.0
	Progress.reset()
	var error := get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
	if error != OK:
		leaving = false
		get_tree().paused = true
		push_error("Could not open the home screen: %s" % error)


func _exit_tree() -> void:
	if is_instance_valid(overlay) and overlay.visible and not leaving:
		get_tree().paused = was_paused
