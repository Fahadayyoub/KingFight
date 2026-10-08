@tool
extends Node2D

func _draw() -> void:
	# Low timber bridge, stone lift tower, then a suspended crossing.
	draw_line(Vector2(300, 6), Vector2(648, 6), Color("536447"), 2)
	for x in [320, 400, 560, 624]:
		draw_rect(Rect2(x - 3, 6, 6, 110), Color("263d31"))
		draw_line(Vector2(x - 22, 6), Vector2(x, 32), Color("40523a"), 2)
	for x in [804, 900]:
		draw_rect(Rect2(x - 14, -202, 28, 310), Color("253337"))
		for y in range(-198, 105, 18):
			draw_line(Vector2(x - 12, y), Vector2(x + 12, y), Color("35474a"), 1)
	draw_line(Vector2(790, -196), Vector2(914, -196), Color("62716a"), 3)
	for step in range(25):
		var fraction := float(step) / 24.0
		var point := Vector2(1168 + 350 * fraction, -152 + 104 * fraction + sin(fraction * PI) * 22)
		draw_circle(point, 1.5, Color("506772"))
	for x in [1168, 1518]:
		draw_line(Vector2(x, -174 if x == 1168 else -64), Vector2(x, 106), Color("293f4b"), 4)
