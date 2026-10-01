extends Node2D

const speed=60
var directon=1

@onready var ray_cast_left: RayCast2D = $KillZone/RayCastLeft
@onready var ray_cast_right: RayCast2D = $KillZone/RayCastRight
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
		if(ray_cast_right.is_colliding()):
			animated_sprite_2d.flip_h=true
			directon=-1
		if(ray_cast_left.is_colliding()):
			animated_sprite_2d.flip_h=false
			directon=1
		position.x += speed * directon * delta
		
