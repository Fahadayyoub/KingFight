extends Control

func _ready() -> void:
	custom_minimum_size = Vector2(80, 24)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Progress.lives_changed.connect(queue_redraw)

func _draw() -> void:
	# Pixel hearts stay legible without depending on font glyph support.
	for index in range(Progress.MAX_LIVES):
		var origin := Vector2(4 + index * 26, 4)
		var color := Color("ef6574") if index < Progress.lives else Color("51494c")
		var rows := ["0110110", "1111111", "1111111", "0111110", "0011100", "0001000"]
		for y in range(rows.size()):
			for x in range(rows[y].length()):
				if rows[y][x] == "1":
					draw_rect(Rect2(origin + Vector2(x, y) * 3.0, Vector2(3, 3)), color)
