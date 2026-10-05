extends Node2D

const SPEED := 60.0
var direction := 1

@onready var ray_cast_left: RayCast2D = $KillZone/RayCastLeft
@onready var ray_cast_right: RayCast2D = $KillZone/RayCastRight
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Turn around at a wall or when the next step has no ground below it.
	var wall_ahead := ray_cast_right.is_colliding() if direction > 0 else ray_cast_left.is_colliding()
	var ahead := global_position + Vector2(direction * 11.0, 0.0)
	var ground_ahead := get_world_2d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters2D.create(ahead, ahead + Vector2(0.0, 20.0), 1)
	)
	if wall_ahead or ground_ahead.is_empty():
		direction *= -1
	animated_sprite_2d.flip_h = direction < 0
	position.x += SPEED * direction * delta
