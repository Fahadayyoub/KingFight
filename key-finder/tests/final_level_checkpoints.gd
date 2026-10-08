extends SceneTree

func _initialize() -> void:
	call_deferred("check_respawns")

func check_respawns() -> void:
	var progress = root.get_node("Progress")
	progress.reset()
	change_scene_to_file("res://scenes/level_10.tscn")
	await process_frame
	await process_frame
	for index in range(5):
		progress.reset()
		var checkpoint = current_scene.get_node("Checkpoint%d" % (index + 1))
		var spawn: Vector2 = checkpoint.respawn_position
		checkpoint.on_body_entered(current_scene.get_node("Player"))
		assert(progress.checkpoint_position == spawn)
		assert(progress.lose_life())
		assert(progress.lives == 2)
		assert(reload_current_scene() == OK)
		await process_frame
		await process_frame
		for frame in range(30):
			await physics_frame
		var player = current_scene.get_node("Player")
		assert(player.is_on_floor())
		assert(player.position.distance_to(spawn) < 2)
		assert(progress.lives == 2 and not progress.dying)
		var hud = current_scene.get_node("CoinHUD/HUD/ProgressHUD")
		assert(hud.checkpoint_xs.size() == 5)
		for flag in range(5):
			assert(hud.checkpoint_unlocked[flag] == (flag <= index))
		print("PASS actual scene reload at checkpoint ", index + 1)
	assert(current_scene.get_node("KingGate").completed_level == 10)
	assert(current_scene.get_node("KingGate").next_scene_path.is_empty())
	for level in range(3,10):
		progress.reset_level()
		assert(change_scene_to_file("res://scenes/level_%d.tscn" % level) == OK)
		await process_frame
		await process_frame
		assert(current_scene.get_node("CoinHUD/HUD/ProgressHUD").checkpoint_xs.size() == (4 if level == 9 else 2))
		if level == 9:
			assert(current_scene.get_node("KingGate").next_scene_path == "res://scenes/level_10.tscn")
	assert(progress.lives == 2, "Level transitions must preserve lives")
	current_scene.queue_free()
	await process_frame
	progress.reset()
	print("PASS: five safe checkpoint reloads, persistent lives, five HUD flags, earlier two-checkpoint HUDs, level 9 -> 10, final gate")
	quit()
