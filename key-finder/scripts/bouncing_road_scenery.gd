@tool
extends Node2D

func _draw() -> void:
	# Orchard silhouettes, a stepped stone balcony, and suspended cables.
	for tree in [Vector2(328, 70), Vector2(480, 90), Vector2(620, 80)]:
		draw_rect(Rect2(tree + Vector2(-4, -65), Vector2(8, 110)), Color("354331"))
		draw_circle(tree + Vector2(-14, -80), 28, Color("253c32"))
		draw_circle(tree + Vector2(14, -84), 32, Color("2b4436"))
	for x in [730, 880, 1038]:
		var top: float = -80.0 - (x - 730) * 0.28
		draw_rect(Rect2(x - 11, top, 22, 230), Color("2b293b"))
		for y in range(int(top), 120, 18):
			draw_line(Vector2(x - 9, y), Vector2(x + 9, y), Color("444050"), 1)
	for step in range(28):
		var fraction := float(step) / 27.0
		draw_circle(Vector2(1190 + 430 * fraction, -166 + 95 * fraction + sin(fraction * PI) * 24), 1.5, Color("726577"))
	for x in [1640, 1780, 1920]:
		draw_line(Vector2(x, -15), Vector2(x, 110), Color("393344"), 4)
