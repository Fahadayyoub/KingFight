@tool
extends Node2D

func _draw() -> void:
	# Distant clockwork towers mark the climb without blocking the route.
	for tower in [Vector2(344, -108), Vector2(480, -170), Vector2(1024, -240), Vector2(1264, -156)]:
		draw_rect(Rect2(tower + Vector2(-13, 0), Vector2(26, 310)), Color("142138"))
		draw_line(tower + Vector2(-8, 0), tower + Vector2(-8, 310), Color("253752"), 2)
		draw_line(tower + Vector2(8, 0), tower + Vector2(8, 310), Color("253752"), 2)
		draw_circle(tower, 17, Color("354260"))
		draw_circle(tower, 11, Color("16233c"))
		for spoke in range(8):
			var direction := Vector2.from_angle(spoke * TAU / 8.0)
			draw_line(tower + direction * 6, tower + direction * 20, Color("596082"), 3)
	for index in range(40):
		var point := Vector2(index * 47 + 12, -290 + (index * 37) % 210)
		draw_circle(point, 1, Color("68718d"))
