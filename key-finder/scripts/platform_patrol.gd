extends Node2D

@export_range(10.0, 100.0, 1.0) var patrol_distance := 50.0
@export_range(10.0, 100.0, 1.0) var speed := 40.0
@export_enum("Left:-1", "Right:1") var direction := 1

var origin_x := 0.0

func _ready() -> void:
	origin_x = position.x
	$AnimatedSprite2D.play(&"default")

func _physics_process(delta: float) -> void:
	var next_x := position.x + speed * direction * delta
	var left := origin_x - patrol_distance
	var right := origin_x + patrol_distance
	if next_x >= right:
		next_x = right - (next_x - right)
		direction = -1
	elif next_x <= left:
		next_x = left + (left - next_x)
		direction = 1
	position.x = clampf(next_x, left, right)
	$AnimatedSprite2D.flip_h = direction < 0
