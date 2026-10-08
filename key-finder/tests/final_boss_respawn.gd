extends SceneTree

func _initialize() -> void:
	call_deferred("check_damage")

func check_damage() -> void:
	var progress = root.get_node("Progress")
	progress.reset()
	change_scene_to_file("res://scenes/level_10.tscn")
	await process_frame
	await process_frame
	var checkpoint = current_scene.get_node("Checkpoint5")
	checkpoint.on_body_entered(current_scene.get_node("Player"))
	var spawn: Vector2 = checkpoint.respawn_position
	var boss = current_scene.get_node("FinalBoss")
	var player = current_scene.get_node("Player")
	player.position = Vector2(5344, -1)
	player.velocity = Vector2.ZERO
	for frame in range(600):
		await physics_frame
		if progress.dying:
			break
	assert(progress.dying and progress.lives == 2)
	assert(boss.health == 8, "A comet that hits the player cannot hurt the boss")
	boss.get_node("Contact")._on_body_entered(player)
	assert(progress.lives == 2, "Duplicate contact cannot consume multiple lives")
	for frame in range(180):
		await physics_frame
	assert(current_scene.get_node("FinalBoss").health == 8)
	assert(not current_scene.get_node("FinalBoss").active)
	assert(current_scene.get_node("KingGate").locked)
	assert(current_scene.get_node("Player").position.distance_to(spawn) < 2)
	assert(progress.lives == 2 and not progress.dying)
	assert(is_equal_approx(Engine.time_scale, 1.0))
	current_scene.queue_free()
	await process_frame
	progress.reset()
	print("PASS: failed dodge costs exactly one life, projectile cannot damage boss after hitting player, arena restarts at checkpoint five with gate locked and full boss health")
	quit()
