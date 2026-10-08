extends Control

const FONT := preload("res://fonts/PixelOperator8-Bold.ttf")
const TRACK_LEFT := 22.0
const TRACK_WIDTH := 416.0

@export var start_x := 13.0
@export var first_checkpoint_name := "MountainCheckpoint"
@export var second_checkpoint_name := "GateCheckpoint"
@export var checkpoint_names: Array[String] = []

var player: CharacterBody2D
var gate_x := 3720.0
var checkpoint_xs: Array[float] = []
var progress_ratio := 0.0
var checkpoint_unlocked: Array[bool] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var game := get_node("../../..")
	player = game.get_node("Player")
	gate_x = game.get_node("KingGate").global_position.x
	var names: Array[String] = checkpoint_names
	if names.is_empty():
		names = [first_checkpoint_name, second_checkpoint_name]
	for checkpoint_name in names:
		checkpoint_xs.append(game.get_node(checkpoint_name).global_position.x)
	checkpoint_unlocked.resize(checkpoint_xs.size())
	checkpoint_unlocked.fill(false)
	refresh()

func _process(_delta: float) -> void:
	refresh()

func refresh() -> void:
	if not is_instance_valid(player):
		return
	Progress.furthest_x = maxf(Progress.furthest_x, player.global_position.x)
	var next_ratio := clampf((Progress.furthest_x - start_x) / (gate_x - start_x), 0.0, 1.0)
	var changed := absf(next_ratio - progress_ratio) > 0.0005
	progress_ratio = next_ratio
	for i in range(checkpoint_xs.size()):
		var unlocked := Progress.has_checkpoint and Progress.checkpoint_position.x >= checkpoint_xs[i]
		if checkpoint_unlocked[i] != unlocked:
			checkpoint_unlocked[i] = unlocked
			changed = true
	if changed:
		queue_redraw()

func stone_center(fraction: float) -> Vector2:
	return Vector2(TRACK_LEFT + TRACK_WIDTH * fraction, 46.0 + sin(fraction * TAU * 1.5) * 4.0)

func hex_points(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for corner in range(6):
		var angle := TAU * float(corner) / 6.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points

func _draw() -> void:
	# A chain of hexagonal stepping stones follows the route instead of a boxed meter.
	draw_string(FONT, Vector2(21, 18), "THE KING'S ROAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("102a2b"))
	draw_string(FONT, Vector2(20, 17), "THE KING'S ROAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ffe3a0"))
	draw_string(FONT, Vector2(252, 18), "%d%%" % roundi(progress_ratio * 100.0), HORIZONTAL_ALIGNMENT_RIGHT, 50, 12, Color("102a2b"))
	draw_string(FONT, Vector2(251, 17), "%d%%" % roundi(progress_ratio * 100.0), HORIZONTAL_ALIGNMENT_RIGHT, 50, 12, Color("ffe3a0"))

	const STONES := 23
	var centers := PackedVector2Array()
	for index in range(STONES):
		centers.append(stone_center(float(index) / float(STONES - 1)))
	draw_polyline(centers, Color("142f31"), 7.0)
	draw_polyline(centers, Color("758f78"), 2.0)
	var nearest := clampi(roundi(progress_ratio * float(STONES - 1)), 0, STONES - 1)
	for index in range(STONES):
		var fraction := float(index) / float(STONES - 1)
		var lit := fraction <= progress_ratio + 0.001
		var center := centers[index]
		var edge := Color("efd78c") if lit else Color("567c73")
		var fill := Color("9abc75") if lit else Color("284a4a")
		draw_colored_polygon(hex_points(center, 10.0), edge)
		draw_colored_polygon(hex_points(center, 7.0), fill)
		if index == nearest:
			draw_circle(center, 3.0, Color("fff3ba"))

	for index in range(checkpoint_xs.size()):
		var fraction := (checkpoint_xs[index] - start_x) / (gate_x - start_x)
		var point := stone_center(fraction)
		var flag_color := Color("ffd47c") if checkpoint_unlocked[index] else Color("91b8ad")
		draw_line(point + Vector2(0, -11), point + Vector2(0, -32), Color("dfc397"), 2.0)
		draw_colored_polygon(PackedVector2Array([
			point + Vector2(1, -32), point + Vector2(20, -27), point + Vector2(1, -22)
		]), flag_color)
		draw_string(FONT, point + Vector2(-13, 29), "CP%d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, 28, 10, flag_color)

	var finish := stone_center(1.0)
	draw_colored_polygon(PackedVector2Array([
		finish + Vector2(-12, -18), finish + Vector2(-9, -34),
		finish + Vector2(-3, -27), finish + Vector2(0, -38),
		finish + Vector2(4, -27), finish + Vector2(10, -34),
		finish + Vector2(12, -18)
	]), Color("f2ca73"))
	draw_string(FONT, finish + Vector2(-16, 29), "GATE", HORIZONTAL_ALIGNMENT_CENTER, 34, 10, Color("ffe1a0"))
