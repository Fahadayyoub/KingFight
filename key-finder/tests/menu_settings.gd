extends SceneTree

func _initialize() -> void:
	call_deferred("check_settings")


func check_settings() -> void:
	var settings = root.get_node("Settings")
	# Keep the player's saved preferences untouched by this test.
	settings.config_path = "/tmp/key_finder_settings_test.cfg"
	settings.set_music_enabled(false)
	assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")))
	settings.set_arrows_on_left(true)
	settings.music_enabled = true
	settings.arrows_on_left = false
	settings.load_preferences()
	assert(not settings.music_enabled and settings.arrows_on_left)
	assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")))
	for level in range(1, 11):
		var path: String = settings.level_scene_for_code(" %s " % settings.level_code_for_level(level).to_lower())
		assert(path == "res://scenes/level_%d.tscn" % level)
		assert(ResourceLoader.exists(path))
	for invalid in ["", "KEY001", "KEY009", "KWY009", "KEY001x", "KEY01", "ZZZ000", "LEVEL1", "res://scenes/level_5.tscn"]:
		assert(settings.level_scene_for_code(invalid).is_empty())
	assert(change_scene_to_file("res://scenes/start_menu.tscn") == OK)
	await process_frame
	await process_frame
	var menu = current_scene
	menu.open_settings()
	assert(menu.settings_overlay.visible)
	assert(not menu.music_toggle.button_pressed and menu.layout_option.selected == 1)
	var progress = root.get_node("Progress")
	progress.lives = 1
	progress.set_checkpoint(Vector2(100, 100))
	menu.level_code_input.text = "wrong"
	menu.code_button.pressed.emit()
	assert(not menu.starting and not menu.code_message.text.is_empty())
	assert(progress.lives == 1 and progress.has_checkpoint)
	menu.music_toggle.button_pressed = true
	assert(settings.music_enabled and not AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")))
	menu.layout_option.item_selected.emit(0)
	assert(not settings.arrows_on_left)
	menu.close_settings()
	assert(not menu.settings_overlay.visible and not menu.start_button.disabled)
	menu.open_settings()
	assert(menu.music_toggle.button_pressed and menu.layout_option.selected == 0)
	# Verify the panel fits within the designed viewport and scales on smaller screens.
	await process_frame
	var panel = menu.settings_overlay.get_child(1)
	assert(panel.position.y + panel.size.y <= 540)
	assert(panel.position.x + panel.size.x <= 960)
	menu.size = Vector2(640, 360)
	menu.layout_canvas()
	assert(is_equal_approx(menu.canvas.scale.x, 2.0 / 3.0))
	menu.level_code_input.text = " %s " % settings.level_code_for_level(4).to_lower()
	menu.level_code_input.text_submitted.emit(menu.level_code_input.text)
	for frame in range(90):
		await process_frame
		if current_scene != menu:
			break
	await process_frame
	await process_frame
	assert(current_scene.scene_file_path == "res://scenes/level_4.tscn")
	assert(progress.lives == 3 and not progress.has_checkpoint)
	# Check both positions and keep arrow order correct after each swap.
	var controls = load("res://scripts/touch_controls.gd").new()
	root.add_child(controls)
	if controls.buttons.is_empty():
		controls.make_button("Left", "ui_left", "<")
		controls.make_button("Right", "ui_right", ">")
		controls.make_button("Jump", "ui_accept", "JUMP")
		settings.controls_changed.connect(controls.layout_buttons)
	settings.set_arrows_on_left(false)
	assert(controls.buttons[2].position.x < controls.buttons[0].position.x)
	settings.set_arrows_on_left(true)
	assert(controls.buttons[0].position.x < controls.buttons[1].position.x)
	assert(controls.buttons[1].position.x < controls.buttons[2].position.x)
	controls.queue_free()
	current_scene.queue_free()
	await process_frame
	assert(change_scene_to_file("res://scenes/start_menu.tscn") == OK)
	await process_frame
	await process_frame
	menu = current_scene
	menu.open_settings()
	menu.level_code_input.text = settings.level_code_for_level(10)
	menu.code_button.pressed.emit()
	for frame in range(90):
		await process_frame
		if current_scene != menu:
			break
	await process_frame
	await process_frame
	assert(current_scene.scene_file_path == "res://scenes/level_10.tscn")
	DirAccess.remove_absolute(settings.config_path)
	print("PASS: persisted sound and controls, valid/invalid codes, menu sizing, direct levels 4 and 10, fresh lives and swapped touch buttons")
	quit()
