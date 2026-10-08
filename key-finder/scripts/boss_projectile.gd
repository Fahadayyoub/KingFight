extends Node2D

const FRUIT := preload("res://sprites/fruit.png")
var boss: Node2D
var direction := Vector2.LEFT
var speed := 190.0
var outbound_distance := 300.0
var travelled := 0.0
var returning := false
var ground_wave := false
var spent := false
var elapsed := 0.0

func _physics_process(delta: float) -> void:
	if spent or not is_instance_valid(boss) or boss.defeated or Progress.dying:
		queue_free()
		return
	elapsed += delta
	var previous := global_position
	if ground_wave:
		global_position.x -= speed * delta
		if global_position.x < boss.arena_left - 40:
			queue_free()
			return
	elif not returning:
		var step := minf(speed * delta, outbound_distance - travelled)
		global_position += direction * step
		travelled += step
		if travelled >= outbound_distance - 0.01:
			returning = true
	else:
		var target: Vector2 = boss.global_position + Vector2(-18, -24)
		global_position = global_position.move_toward(target, speed * delta)
		if global_position.distance_to(target) < 1.0:
			spent = true
			boss.take_return_hit(self)
			queue_free()
			return
	var player: CharacterBody2D = boss.player
	if is_instance_valid(player):
		var center := player.global_position + Vector2(0, -6)
		if ground_wave:
			if absf(center.x - global_position.x) < 11.0 and center.y > global_position.y - 13.0 and center.y < global_position.y + 5.0:
				hit_player(player)
		else:
			var closest := Geometry2D.get_closest_point_to_segment(center, previous, global_position)
			if center.distance_to(closest) < 10.0:
				hit_player(player)
	queue_redraw()

func hit_player(body: CharacterBody2D) -> void:
	spent = true
	boss.get_node("Contact")._on_body_entered(body)
	queue_free()

func _draw() -> void:
	if ground_wave:
		draw_rect(Rect2(-6, -8, 12, 8), Color("f6ab63"))
		draw_line(Vector2(-7, -9), Vector2(7, -9), Color("fff0a2"), 2)
	else:
		draw_circle(Vector2.ZERO, 8, Color(0.95, 0.5, 0.2, 0.25))
		draw_arc(Vector2.ZERO, 7, elapsed * 7, elapsed * 7 + PI * 1.5, 14, Color("ffe4a0") if returning else Color("ee9867"), 1.5)
		draw_texture_rect_region(FRUIT, Rect2(-6, -6, 12, 12), Rect2(0, 0, 16, 16))
