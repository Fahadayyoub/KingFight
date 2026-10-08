@tool
extends Node2D

func _draw() -> void:
	# Each region has its own silhouette and construction style.
	for x in [340, 520, 710]:
		draw_rect(Rect2(x - 16, -25, 32, 135), Color("3c342f"))
		for tooth in range(3):
			draw_rect(Rect2(x - 18 + tooth * 13, -35, 10, 14), Color("56493d"))
	for x in [920, 1120, 1400]:
		var top: float = -140.0 - (x - 920) * 0.3
		draw_rect(Rect2(x - 13, top, 26, 420), Color("263844"))
		for y in range(int(top), 112, 20):
			draw_line(Vector2(x - 11, y), Vector2(x + 11, y), Color("354c58"), 1)
	for index in range(45):
		var t := float(index) / 44.0
		draw_circle(Vector2(1620 + 720 * t, -278 + 220 * t + sin(t * PI) * 30), 1.5, Color("65737c"))
	for x in [2460, 2590, 2880, 3040]:
		draw_line(Vector2(x, -4), Vector2(x, 115), Color("3b4638"), 5)
		draw_circle(Vector2(x, 70), 32, Color("27392f"))
	for x in [3270, 3440, 3750, 4080]:
		draw_rect(Rect2(x - 18, -260 if x < 3550 else -156, 36, 460), Color("352e47"))
		draw_line(Vector2(x, -256 if x < 3550 else -152), Vector2(x, 120), Color("504561"), 2)
