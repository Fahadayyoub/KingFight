extends Area2D

@onready var game_manger: Node = %GameManger
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

var collected := false


func _on_body_entered(_body: Node2D) -> void:
	if collected:
		return

	collected = true
	$AnimatedSprite2D.hide()
	$AnimatedSprite2D.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("monitoring", false)
	game_manger.add_point()
	pickup_sound.play()
	await pickup_sound.finished
	queue_free()
