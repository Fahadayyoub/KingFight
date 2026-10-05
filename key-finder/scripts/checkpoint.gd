@tool
extends Area2D

@export var respawn_position := Vector2.ZERO
var activated := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(on_body_entered)
	if Progress.has_checkpoint and Progress.checkpoint_position == respawn_position:
		activated = true
	queue_redraw()

func on_body_entered(body: Node2D) -> void:
	if body.name != "Player" or activated:
		return
	activated = true
	Progress.set_checkpoint(respawn_position)
	$Sound.play()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-2,-53,4,54), Color("b2a785"))
	var color := Color("f0cd77") if activated else Color("6cbbb1")
	draw_colored_polygon(PackedVector2Array([Vector2(2,-51),Vector2(32,-44),Vector2(2,-33)]), color)
	draw_circle(Vector2(0,-53),4,Color("ffe2a0"))
