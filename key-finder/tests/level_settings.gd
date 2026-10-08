extends SceneTree

func _initialize() -> void:
	call_deferred("check_settings")


func check_settings() -> void:
	var settings = root.get_node("Settings")
	settings.config_path = "/tmp/key_finder_level_settings_test.cfg"
	settings.set_music_enabled(true)
	var progress = root.get_node("Progress")
	for level in range(1, 11):
		progress.reset()
		assert(change_scene_to_file("res://scenes/level_%d.tscn" % level) == OK)
		await process_frame
		await process_frame
		var menu = current_scene.get_node("LevelSettings")
		assert(menu.settings_button.visible)
		var player = current_scene.get_node("Player")
		Input.action_press("ui_right")
		menu.settings_button.pressed.emit()
		assert(paused and menu.overlay.visible)
		assert(not Input.is_action_pressed("ui_right"))
		assert(root.get_node("GameMusic").can_process())
		for button in current_scene.find_children("*", "TouchScreenButton", true, false):
			assert(not button.visible)
		var position: Vector2 = player.position
		for frame in range(10):
			await process_frame
		assert(player.position == position, "The player must remain safe while settings are open")
		menu.music_toggle.button_pressed = false
		assert(not settings.music_enabled)
		assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")))
		assert(not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")))
		assert(not AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))
		settings.music_enabled = true
		settings.load_preferences()
		assert(not settings.music_enabled, "Music choice must persist")
		menu.close_settings()
		assert(not paused and not menu.overlay.visible)
		for button in current_scene.find_children("*", "TouchScreenButton", true, false):
			assert(button.visible)
		menu.open_settings()
		assert(not menu.music_toggle.button_pressed)
		menu.music_toggle.button_pressed = true
		assert(settings.music_enabled and not AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")))
		menu.close_settings()
		progress.dying = true
		menu.open_settings()
		assert(not paused and not menu.overlay.visible, "Do not interrupt a death transition")
		progress.dying = false
		progress.lives = 1
		progress.set_checkpoint(Vector2(120, -30))
		menu.open_settings()
		menu.home_button.pressed.emit()
		await process_frame
		await process_frame
		assert(current_scene.scene_file_path == "res://scenes/start_menu.tscn")
		assert(not paused and Engine.time_scale == 1.0)
		assert(progress.lives == 3 and not progress.has_checkpoint)
		print("PASS level %d: pause/resume, music, saved choice and home" % level)
	DirAccess.remove_absolute(settings.config_path)
	print("PASS: settings work in all ten levels")
	quit()
