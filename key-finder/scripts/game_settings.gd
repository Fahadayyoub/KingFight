extends Node

signal controls_changed
signal music_changed(enabled: bool)

# Fixed replay codes stay valid across app launches and preference changes.
const LEVEL_CODES: Array[String] = [
	"UCJ685", # Level 1
	"GCT405", # Level 2
	"HMF381", # Level 3
	"HZK477", # Level 4
	"QUA291", # Level 5
	"SXN165", # Level 6
	"BCV316", # Level 7
	"VKM361", # Level 8
	"VLW700", # Level 9
	"HQB396", # Level 10
]

var music_enabled := true
var arrows_on_left := false
var config_path := "user://settings.cfg"


func _enter_tree() -> void:
	# Restore saved audio before the music autoload enters and starts playback.
	load_preferences()


func load_preferences() -> void:
	var config := ConfigFile.new()
	music_enabled = true
	arrows_on_left = false
	if config.load(config_path) == OK:
		var sound: Variant = config.get_value("settings", "sound_enabled", true)
		var music: Variant = config.get_value("settings", "music_enabled", true)
		if music is bool:
			music_enabled = music
		var controls: Variant = config.get_value("settings", "arrows_on_left", false)
		# Preserve a previously muted main-menu sound preference during migration.
		if sound is bool and not sound:
			music_enabled = false
		if controls is bool:
			arrows_on_left = controls
	apply_sound()
	controls_changed.emit()
	music_changed.emit(music_enabled)


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	apply_sound()
	save_preferences()
	music_changed.emit(music_enabled)


func set_arrows_on_left(enabled: bool) -> void:
	arrows_on_left = enabled
	controls_changed.emit()
	save_preferences()


func apply_sound() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not music_enabled)


func save_preferences() -> void:
	var config := ConfigFile.new()
	config.set_value("settings", "music_enabled", music_enabled)
	config.set_value("settings", "arrows_on_left", arrows_on_left)
	var error := config.save(config_path)
	if error != OK:
		push_warning("Could not save game settings: %s" % error)


func level_code_for_level(level: int) -> String:
	return LEVEL_CODES[level - 1] if level >= 1 and level <= LEVEL_CODES.size() else ""


func level_scene_for_code(code: String) -> String:
	var normalized := code.strip_edges().to_upper()
	for level in range(1, LEVEL_CODES.size() + 1):
		if normalized == level_code_for_level(level):
			return "res://scenes/level_%d.tscn" % level
	return ""
