"""Verify saved audio settings across fresh Godot launches using isolated storage."""
import pathlib
import shutil
import subprocess
import sys
import tempfile

project = pathlib.Path(__file__).resolve().parents[1]
godot = sys.argv[1] if len(sys.argv) > 1 else "godot"

with tempfile.TemporaryDirectory(prefix="key_finder_audio_restart_") as directory:
    fixture = pathlib.Path(directory)
    (fixture / "scripts").mkdir()
    (fixture / "scenes").mkdir()
    (fixture / "music").mkdir()
    # Exercise the real startup/save code while leaving player preferences untouched.
    source = (project / "scripts/game_settings.gd").read_text()
    source = source.replace('"user://settings.cfg"', f'"{fixture}/settings.cfg"')
    (fixture / "scripts/game_settings.gd").write_text(source)
    shutil.copy(project / "default_bus_layout.tres", fixture)
    shutil.copy(project / "music/time_for_adventure.mp3", fixture / "music")
    music_scene = (project / "scenes/game_music.tscn").read_text()
    music_scene = music_scene.replace('\n[node name=', '\n[ext_resource type="Script" path="res://scripts/music_startup_probe.gd" id="startup_probe"]\n\n[node name=', 1)
    music_scene += '\nscript = ExtResource("startup_probe")\n'
    (fixture / "scenes/game_music.tscn").write_text(music_scene)
    (fixture / "project.godot").write_text('''config_version=5
[application]
config/name="Key Finder Audio Restart Test"
[audio]
buses/default_bus_layout="res://default_bus_layout.tres"
[autoload]
Settings="*res://scripts/game_settings.gd"
GameMusic="*res://scenes/game_music.tscn"
[rendering]
renderer/rendering_method="gl_compatibility"
''')
    (fixture / "scripts/music_startup_probe.gd").write_text('''extends AudioStreamPlayer

func _enter_tree() -> void:
    var args := OS.get_cmdline_user_args()
    if args[0] == "read":
        var music := args[1] == "on"
        assert(Settings.music_enabled == music)
        assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")) == false)
        assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")) == not music)
        print("PASS saved audio restored before music enters the tree")
''')
    (fixture / "check.gd").write_text('''extends SceneTree

func _initialize() -> void:
    call_deferred("check_audio")

func check_audio() -> void:
    var args := OS.get_cmdline_user_args()
    var settings = root.get_node("Settings")
    var music := args[1] == "on"
    if args[0] == "write":
        settings.set_music_enabled(music)
        assert(FileAccess.file_exists(settings.config_path))
    else:
        assert(settings.music_enabled == music)
        assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")) == false)
        assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")) == not music)
    print("PASS ", args[0], " music=", args[1])
    quit()
''')
    subprocess.run([godot, "--headless", "--path", str(fixture), "--editor", "--import", "--quit"], check=True, capture_output=True)
    for music in ["off", "on"]:
        for mode in ["write", "read"]:
            result = subprocess.run([godot, "--headless", "--path", str(fixture), "--script", "res://check.gd", "--quit-after", "120", "--", mode, music], check=True, capture_output=True, text=True)
            output = result.stdout + result.stderr
            assert "SCRIPT ERROR" not in output, output
            assert f"PASS {mode} music={music}" in output, output
            if mode == "read":
                assert "PASS saved audio restored before music enters the tree" in output, output
            print(f"PASS fresh launch: {mode}, music={music}")
print("PASS: all audio preferences survive full process restarts and apply before music startup")
