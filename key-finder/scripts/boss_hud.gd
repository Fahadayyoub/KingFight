extends Control

const FONT := preload("res://fonts/PixelOperator8-Bold.ttf")
var boss: Node2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(boss):
		return
	draw_rect(Rect2(0, 0, 460, 64), Color(0.05, 0.07, 0.12, 0.94))
	draw_rect(Rect2(0, 0, 460, 64), Color("b18b65"), false, 2)
	var color := Color("ef956c") if boss.health <= boss.MAX_HEALTH / 2 else Color("c391e8")
	draw_string(FONT, Vector2(12, 17), "THE CROWN SLIME", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)
	draw_string(FONT, Vector2(366, 17), "%d / %d" % [boss.health, boss.MAX_HEALTH], HORIZONTAL_ALIGNMENT_RIGHT, 80, 12, Color("fff0bb"))
	draw_rect(Rect2(12, 25, 436, 9), Color("3b304b"))
	draw_rect(Rect2(12, 25, 436 * float(boss.health) / boss.MAX_HEALTH, 9), color)
	var hint := "DODGE THE COMET. ITS RETURN HURTS THE BOSS."
	if boss.health <= boss.MAX_HEALTH / 2:
		hint = "DODGE COMETS. JUMP OVER THE GROUND WAVES."
	if boss.defeated:
		hint = "BOSS DEFEATED! WALK RIGHT TO THE FINAL GATE."
	draw_string(FONT, Vector2(12, 52), hint, HORIZONTAL_ALIGNMENT_CENTER, 436, 10, Color("ffe4a0"))
