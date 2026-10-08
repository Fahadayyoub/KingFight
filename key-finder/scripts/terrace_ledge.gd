@tool
extends StaticBody2D

const TEXTURE := preload("res://sprites/platforms.png")
@export_range(24.0, 200.0, 2.0) var width := 64.0:
	set(value):
		width = value
		queue_redraw()
		if is_node_ready():
			update_collision()

func _ready() -> void:
	update_collision()

func update_collision() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 8)
	$CollisionShape2D.shape = shape

func _draw() -> void:
	# Repeat the pixel art at its original scale instead of stretching a tiny platform.
	var x := -width / 2.0
	while x < width / 2.0:
		var segment := minf(32.0, width / 2.0 - x)
		draw_texture_rect_region(TEXTURE, Rect2(x, -4, segment, 9), Rect2(16, 0, segment, 9))
		x += segment
