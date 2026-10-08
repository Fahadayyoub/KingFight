extends SceneTree

func _initialize() -> void:
	call_deferred("check_codes")


func check_codes() -> void:
	var settings = root.get_node("Settings")
	var progress = root.get_node("Progress")
	var format := RegEx.new()
	assert(format.compile("^[A-Z]{3}[0-9]{3}$") == OK)
	var seen_codes: Array[String] = []
	assert(settings.level_code_for_level(0).is_empty())
	assert(settings.level_code_for_level(11).is_empty())
	for level in range(1, 11):
		progress.reset()
		var path := "res://scenes/level_%d.tscn" % level
		assert(change_scene_to_file(path) == OK)
		await process_frame
		await process_frame
		var gate = current_scene.get_node("KingGate")
		gate.show_victory()
		await process_frame
		var code_label = current_scene.get_node("VictoryMenu").find_child("ReplayCode", true, false)
		var continue_button = current_scene.get_node("VictoryMenu").find_child("ContinueButton", true, false)
		var code: String = code_label.text.trim_prefix("REPLAY CODE: ")
		assert(code == settings.level_code_for_level(level))
		assert(not seen_codes.has(code), "Each level must have its own unique code")
		seen_codes.append(code)
		assert(format.search(code) != null, "Code must contain three letters and three numbers")
		assert(code_label.get_parent() == continue_button.get_parent(), "Code must sit beside the next-level button")
		assert(settings.level_scene_for_code(code) == path)
		assert(continue_button.text == ("NEXT LEVEL" if level < 10 else "PLAY AGAIN"))
		continue_button.pressed.emit()
		await process_frame
		await process_frame
		assert(current_scene.scene_file_path == ("res://scenes/level_%d.tscn" % (level + 1) if level < 10 else "res://scenes/start_menu.tscn"))
		assert(change_scene_to_file("res://scenes/start_menu.tscn") == OK)
		await process_frame
		await process_frame
		var menu = current_scene
		menu.open_settings()
		menu.level_code_input.text = code
		menu.code_button.pressed.emit()
		for frame in range(90):
			await process_frame
			if current_scene != menu:
				break
		await process_frame
		await process_frame
		assert(current_scene.scene_file_path == path)
		assert(progress.lives == 3 and not progress.has_checkpoint)
		print("PASS completed level %d: displayed replay code, next button, Settings replay" % level)
	print("PASS: all ten completion codes reopen the matching level through main-menu Settings")
	quit()
