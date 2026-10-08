@tool
extends "res://scripts/kingdom_trial_scenery.gd"

func _draw() -> void:
	super._draw()
	# Elevated rigging follows the final level's rising chasm.
	for step in range(34):
		var t := float(step) / 33.0
		draw_circle(Vector2(1610 + 740 * t, -290 - sin(t * PI) * 88 + 20 * t), 1, Color("64586e"))
	# Storm approach and throne room pillars.
	for x in [4480, 4720, 5040]:
		draw_rect(Rect2(x - 14, -174, 28, 310), Color("303445"))
	for x in [5340, 5500, 5700, 5840]:
		draw_rect(Rect2(x - 12, -148, 24, 256), Color("31293c"))
		draw_rect(Rect2(x - 18, -154, 36, 10), Color("514054"))
		draw_rect(Rect2(x - 17, -110, 34, 50), Color("64374e"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-17,-60),Vector2(x,-46),Vector2(x+17,-60)]),Color("64374e"))
	for index in range(30):
		var point := Vector2(4460 + index * 47, -206 + (index * 31) % 110)
		draw_circle(point, 1, Color("8b7186"))
