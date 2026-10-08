extends SceneTree

func _initialize() -> void:
	call_deferred("check_music")

func check_music() -> void:
	var settings = root.get_node("Settings")
	settings.config_path = "/tmp/key_finder_shared_music_test.cfg"
	# Previously saved master mute must migrate into the shared music switch.
	var legacy := ConfigFile.new()
	legacy.set_value("settings", "sound_enabled", false)
	legacy.set_value("settings", "music_enabled", true)
	assert(legacy.save(settings.config_path) == OK)
	settings.load_preferences()
	assert(not settings.music_enabled)
	assert(not AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))
	for enabled in [true, false]:
		assert(change_scene_to_file("res://scenes/start_menu.tscn") == OK)
		await process_frame
		await process_frame
		var menu = current_scene
		menu.open_settings()
		menu.music_toggle.button_pressed = enabled
		assert(settings.music_enabled == enabled)
		menu.level_code_input.text = settings.level_code_for_level(4)
		menu.code_button.pressed.emit()
		for frame in range(90):
			await process_frame
			if current_scene != menu:
				break
		await process_frame
		await process_frame
		var level_menu = current_scene.get_node("LevelSettings")
		level_menu.open_settings()
		assert(level_menu.music_toggle.button_pressed == enabled)
		assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")) == not enabled)
		level_menu.music_toggle.button_pressed = not enabled
		assert(settings.music_enabled == not enabled)
		# Shared change notifications also update a switch while its panel is open.
		settings.set_music_enabled(enabled)
		assert(level_menu.music_toggle.button_pressed == enabled)
		level_menu.music_toggle.button_pressed = not enabled
		level_menu.home_button.pressed.emit()
		await process_frame
		await process_frame
		current_scene.open_settings()
		assert(current_scene.music_toggle.button_pressed == not enabled)
		settings.music_enabled = enabled
		settings.load_preferences()
		assert(settings.music_enabled == not enabled)
		assert(current_scene.music_toggle.button_pressed == not enabled)
		var saved := ConfigFile.new()
		assert(saved.load(settings.config_path) == OK)
		assert(not saved.has_section_key("settings", "sound_enabled"))
	DirAccess.remove_absolute(settings.config_path)
	print("PASS: shared music switch, both directions between menu and level, live updates, persistence and legacy mute migration")
	quit()
