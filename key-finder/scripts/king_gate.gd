@tool
extends Node2D

const FONT := preload("res://fonts/PixelOperator8-Bold.ttf")
@export_file("*.tscn") var next_scene_path := ""
@export var completed_level := 1

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
	if body.name == "Player" and not opening:
		opening = true
		$OpenSound.play()

func _draw() -> void:
	# Stone columns, crown-shaped lintel, and two doors sliding apart.
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
	overlay.layer = 20
	get_tree().current_scene.add_child(overlay)
	var veil := ColorRect.new()
	veil.color = Color(0.04, 0.11, 0.13, 0.8)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(veil)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.position = Vector2(-180, -70)
	box.custom_minimum_size = Vector2(360, 150)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	veil.add_child(box)
	var title := Label.new()
	title.text = "LEVEL %d COMPLETE!" % completed_level if not next_scene_path.is_empty() else "THE KING'S GATE IS OPEN!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("ffe2a0"))
	box.add_child(title)
	var message := Label.new()
	message.text = "Ready for the next level?" if not next_scene_path.is_empty() else "You completed the kingdom trail."
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_override("font", FONT)
	message.add_theme_font_size_override("font_size", 14)
	box.add_child(message)
	var again := Button.new()
	again.text = "NEXT LEVEL" if not next_scene_path.is_empty() else "PLAY AGAIN"
	again.add_theme_font_override("font", FONT)
	again.add_theme_font_size_override("font_size", 16)
	box.add_child(again)
	again.pressed.connect(func():
		Progress.reset()
		if next_scene_path.is_empty():
			get_tree().reload_current_scene()
		else:
			var error := get_tree().change_scene_to_file(next_scene_path)
			if error != OK:
				push_error("Could not open the next level: %s" % error)
	)
	again.grab_focus()
