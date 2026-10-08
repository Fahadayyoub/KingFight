extends SceneTree

func _initialize() -> void:
	call_deferred("fight")

func fight() -> void:
	var progress = root.get_node("Progress")
	progress.reset()
	change_scene_to_file("res://scenes/level_10.tscn")
	await process_frame
	await process_frame
	var scene = current_scene
	var boss = scene.get_node("FinalBoss")
	var gate = scene.get_node("KingGate")
	var player = scene.get_node("Player")
	assert(gate.locked)
	gate._on_body_entered(player)
	assert(not gate.opening, "Gate must reject entry before boss defeat")
	player.position = Vector2(5344, -1)
	player.velocity = Vector2.ZERO
	var return_hits := 0
	var last_health: int = boss.health
	var saw_wave := false
	var saw_return := false
	for frame in range(7000):
		await physics_frame
		assert(progress.lives == 3, "Boss should be beatable by timed jumps")
		var imminent := false
		for projectile in boss.projectiles:
			if not is_instance_valid(projectile) or projectile.spent:
				continue
			if projectile.ground_wave:
				saw_wave = true
				var gap: float = projectile.position.x - player.position.x
				if gap > 0 and gap < 45:
					imminent = true
			else:
				saw_return = saw_return or projectile.returning
				var gap: float = projectile.position.x - player.position.x
				if not projectile.returning and gap > 0 and gap < 38:
					imminent = true
		if imminent and player.is_on_floor():
			player.velocity.y = -300
		if boss.health != last_health:
			assert(boss.health == last_health - 1)
			last_health = boss.health
			return_hits += 1
			print("PASS returned comet damage: boss health ", boss.health)
		if boss.defeated:
			break
	assert(boss.defeated and boss.health == 0)
	assert(return_hits == 8 and saw_return and saw_wave)
	assert(not gate.locked)
	await physics_frame
	assert(boss.get_node("Contact/CollisionShape2D").disabled)
	Input.action_press("ui_right")
	for frame in range(800):
		await physics_frame
		if gate.won:
			break
	Input.action_release("ui_right")
	assert(gate.won, "Player must reach the victory gate after defeat")
	var titles = scene.find_children("*", "Label", true, false)
	var has_final_title := false
	for title in titles:
		has_final_title = has_final_title or title.text == "KINGDOM SAVED!"
	assert(has_final_title)
	var replay: Button
	for button in scene.find_children("*", "Button", true, false):
		if button.text == "PLAY AGAIN":
			replay = button
	assert(replay != null)
	replay.pressed.emit()
	await process_frame
	await process_frame
	assert(current_scene.scene_file_path == "res://scenes/start_menu.tscn")
	assert(progress.lives == 3 and not progress.has_checkpoint)
	print("PASS: complete eight-hit boss fight using jumps only, phase-two ground waves, blocked gate, final victory and replay menu")
	current_scene.queue_free()
	await process_frame
	quit()
