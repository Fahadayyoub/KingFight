@tool
extends AnimatableBody2D

@export var travel := Vector2(24, 0)
@export_range(2.0, 12.0, 0.1) var cycle_seconds := 4.5
@export_range(0.0, 1.0, 0.05) var phase := 0.0

var origin := Vector2.ZERO
var elapsed := 0.0

func _ready() -> void:
	origin = position
	if Engine.is_editor_hint():
		return
	# Animatable bodies transfer their motion to a character standing on them.
	sync_to_physics = true
	position = origin + travel * sin(phase * TAU)
	if travel.x != 0 and travel.y != 0:
		$Sprite2D.modulate = Color("c5a7f2")
	else:
		$Sprite2D.modulate = Color("8fe0da") if travel.x != 0 else Color("ffe0a0")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	elapsed += delta
	position = origin + travel * sin((elapsed / cycle_seconds + phase) * TAU)
	queue_redraw()

func _draw() -> void:
	# A faint stationary dotted track shows where the platform will travel.
	var center := Vector2.ZERO if Engine.is_editor_hint() else origin - position
	for step in range(9):
		var point := center + travel * (float(step) / 4.0 - 1.0)
		draw_circle(point + Vector2(0, 12), 1.0, Color(0.65, 0.85, 0.8, 0.4))
