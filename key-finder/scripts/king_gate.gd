@tool
extends Node2D

const FONT := preload("res://fonts/PixelOperator8-Bold.ttf")
@export_file("*.tscn") var next_scene_path := ""
@export var completed_level := 1
@export var locked := false
@export var victory_title := ""
@export var victory_message := ""
@export_file("*.tscn") var restart_scene_path := ""

var opening := false
var open_amount := 0.0
var won := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	$Approach.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if opening and open_amount < 1.0:
		open_amount = minf(1.0, open_amount + delta * 0.8)
		if open_amount >= 1.0:
			$GateBlock/CollisionShape2D.set_deferred("disabled", true)
		queue_redraw()
	if opening and open_amount >= 1.0 and not won:
		var player := get_tree().current_scene.get_node_or_null("Player")
		if player != null and player.global_position.x > global_position.x + 34.0:
			won = true
			show_victory()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not opening and not locked:
		opening = true
		$OpenSound.play()

func unlock() -> void:
	locked = false
	queue_redraw()
	for body in $Approach.get_overlapping_bodies():
		_on_body_entered(body)

func _draw() -> void:
	# Stone columns, crown-shaped lintel, and two doors sliding apart.
	if locked:
		draw_string(FONT, Vector2(-58, -124), "DEFEAT THE BOSS", HORIZONTAL_ALIGNMENT_CENTER, 116, 8, Color("ef8797"))
	draw_rect(Rect2(-35, -91, 70, 11), Color("3b4b49"))
	draw_rect(Rect2(-36, -80, 11, 80), Color("5b7062"))
	draw_rect(Rect2(25, -80, 11, 80), Color("5b7062"))
	draw_rect(Rect2(-38, -4, 76, 8), Color("344744"))
	for i in range(5):
		draw_rect(Rect2(-32 + i * 14, -101, 9, 15 if i % 2 == 0 else 9), Color("e2bb70"))
	for side: int in [-1, 1]:
		var slide := open_amount * 21.0 * side
		var x := -24.0 if side < 0 else 1.0
		draw_rect(Rect2(x + slide, -79, 23, 75), Color("755a45"))
		draw_rect(Rect2(x + slide + 3, -74, 17, 67), Color("96744d"))
		draw_rect(Rect2(x + slide + 9, -52, 5, 5), Color("f1cc76"))
	draw_string(FONT, Vector2(-25, -108), "KING", HORIZONTAL_ALIGNMENT_CENTER, 50, 10, Color("ffe2a0"))

func show_victory() -> void:
	var overlay := CanvasLayer.new()
	overlay.name = "VictoryMenu"
	overlay.layer = 20
	get_tree().current_scene.add_child(overlay)
	var veil := ColorRect.new()
	veil.color = Color(0.04, 0.11, 0.13, 0.8)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(veil)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(640, 180)
	box.add_theme_constant_override("separation", 14)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(box)
	var title := Label.new()
	title.text = "LEVEL %d COMPLETE!" % completed_level if not next_scene_path.is_empty() else "THE KING'S GATE IS OPEN!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("ffe2a0"))
	if not victory_title.is_empty():
		title.text = victory_title
	box.add_child(title)
	var message := Label.new()
	message.text = "Ready for the next level?" if not next_scene_path.is_empty() else "You completed the kingdom trail."
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_override("font", FONT)
	message.add_theme_font_size_override("font_size", 14)
	if not victory_message.is_empty():
		message.text = victory_message
	box.add_child(message)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 20)
	box.add_child(actions)
	var replay_code := Label.new()
	replay_code.name = "ReplayCode"
	replay_code.text = "REPLAY CODE: %s" % Settings.level_code_for_level(completed_level)
	replay_code.add_theme_font_override("font", FONT)
	replay_code.add_theme_font_size_override("font_size", 14)
	replay_code.add_theme_color_override("font_color", Color("ffe2a0"))
	actions.add_child(replay_code)
	var again := Button.new()
	again.name = "ContinueButton"
	again.custom_minimum_size = Vector2(210, 48)
	again.text = "NEXT LEVEL" if not next_scene_path.is_empty() else "PLAY AGAIN"
	again.add_theme_font_override("font", FONT)
	again.add_theme_font_size_override("font_size", 16)
	actions.add_child(again)
	var code_hint := Label.new()
	code_hint.text = "Replay this level: Home > Settings."
	code_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_hint.add_theme_font_override("font", FONT)
	code_hint.add_theme_font_size_override("font_size", 12)
	code_hint.add_theme_color_override("font_color", Color("a9c8b2"))
	box.add_child(code_hint)
	again.pressed.connect(func():
		if next_scene_path.is_empty():
			Progress.reset()
			if restart_scene_path.is_empty():
				get_tree().reload_current_scene()
			else:
				get_tree().change_scene_to_file(restart_scene_path)
		else:
			Progress.reset_level()
			var error := get_tree().change_scene_to_file(next_scene_path)
			if error != OK:
				push_error("Could not open the next level: %s" % error)
	)
	again.grab_focus()
