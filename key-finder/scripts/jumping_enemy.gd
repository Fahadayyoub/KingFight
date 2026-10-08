extends Node2D

const GRAVITY := 800.0
const GREEN_SLIME := preload("res://sprites/slime_green.png")
@export_range(24.0, 64.0, 1.0) var jump_height := 44.0
@export_range(0.3, 2.0, 0.05) var rest_seconds := 0.8
@export_range(0.0, 2.0, 0.05) var initial_delay := 0.3

var floor_y := 0.0
var jump_velocity_y := 0.0
var cooldown := 0.0
var airborne := false

func _ready() -> void:
	floor_y = position.y
	cooldown = initial_delay
	var frames := SpriteFrames.new()
	frames.set_animation_speed(&"default", 10.0)
	for index in range(4):
		var texture := AtlasTexture.new()
		texture.atlas = GREEN_SLIME
		texture.region = Rect2(index * 24, 24, 24, 24)
		frames.add_frame(&"default", texture)
	$AnimatedSprite2D.sprite_frames = frames
	$AnimatedSprite2D.play(&"default")

func _physics_process(delta: float) -> void:
	if not airborne:
		cooldown -= delta
		$AnimatedSprite2D.scale = Vector2(1.15, 0.85) if cooldown < 0.18 else Vector2.ONE
		$AnimatedSprite2D.position.y = -12.0 * $AnimatedSprite2D.scale.y
		if cooldown <= 0.0:
			airborne = true
			jump_velocity_y = -sqrt(2.0 * GRAVITY * jump_height)
			$AnimatedSprite2D.scale = Vector2.ONE
			$AnimatedSprite2D.position.y = -12.0
		return
	position.y += jump_velocity_y * delta + 0.5 * GRAVITY * delta * delta
	jump_velocity_y += GRAVITY * delta
	if position.y >= floor_y and jump_velocity_y > 0.0:
		position.y = floor_y
		jump_velocity_y = 0.0
		airborne = false
		cooldown = rest_seconds
