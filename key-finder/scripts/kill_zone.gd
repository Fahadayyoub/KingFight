extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D or not Progress.lose_life():
		return
	Engine.time_scale = 0.5
	body.set_physics_process(false)
	body.get_node("CollisionShape2D").set_deferred("disabled", true)
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	if Progress.lives > 0:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
