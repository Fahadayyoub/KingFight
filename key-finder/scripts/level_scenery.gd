@tool
extends Node2D

# Distant shapes are kept behind the collision tiles and remain visible in the editor.
func _draw() -> void:
	for index in range(8):
		var x := 2020.0 + index * 230.0
		var peak := -122.0 - float(index % 3) * 14.0
		var back := PackedVector2Array([Vector2(x - 160, 88), Vector2(x, peak), Vector2(x + 170, 88)])
		draw_colored_polygon(back, Color("163b42"))
		var front := PackedVector2Array([Vector2(x - 78, 88), Vector2(x + 30, peak + 45), Vector2(x + 145, 88)])
		draw_colored_polygon(front, Color("24564b"))
		draw_colored_polygon(PackedVector2Array([Vector2(x - 19, peak + 20), Vector2(x, peak), Vector2(x + 24, peak + 23), Vector2(x + 2, peak + 16)]), Color("8ba996"))
	# Gold and teal hexagons mark the alternate high route through the ruins.
	for index in range(17):
		var center := Vector2(2810.0 + index * 45.0, -78.0 + float(index % 3) * 18.0)
		var points := PackedVector2Array()
		for corner in range(6):
			var angle := TAU * float(corner) / 6.0
			points.append(center + Vector2(cos(angle), sin(angle)) * 14.0)
		draw_colored_polygon(points, Color(0.27, 0.58, 0.52, 0.55))
		points.append(points[0])
		draw_polyline(points, Color("e4bf73"), 2.0)
