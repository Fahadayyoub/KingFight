# Final level checks

Run from the project directory with Godot 4:

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/final_boss_victory.gd --quit-after 9000
godot --headless --path . --fixed-fps 60 --script res://tests/final_boss_respawn.gd --quit-after 3000
godot --headless --path . --fixed-fps 60 --script res://tests/final_level_checkpoints.gd --quit-after 3000
```

These exercise the complete boss fight using timed jumps, damage and restart after a missed dodge, all five checkpoint reloads, earlier checkpoint HUDs, final victory, and replay. Success prints `PASS`; script errors or assertion failures indicate a failure.

Menu settings checks (uses a temporary settings file):

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/menu_settings.gd --quit-after 1000
```

Checks music muting and saved preferences, both touch layouts, invalid codes, and direct menu launches into levels 4 and 10. Each level has a fixed unique code of three letters and three numbers, displayed on its completion screen. Code entry ignores case and surrounding spaces.

In-level settings checks:

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/level_settings.gd --quit-after 1500
```

Checks all ten levels for paused gameplay, released and hidden touch controls, music-only muting and persistence, safe resume, and a return to the home screen with fresh progress.

Completion replay code checks:

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/victory_level_codes.gd --quit-after 1800
```

Checks every completion screen displays its finished level's replay code beside the continue button, preserves Next Level / Play Again navigation, and reopens that same level by entering the displayed code in main-menu Settings.

Audio persistence across app restarts:

```sh
python3 tests/audio_preferences_restart.py godot
```

Runs separate Godot processes to save and restore music on and off, and verifies the saved bus mute states apply before the music player enters the scene. Uses temporary storage without changing the player's preferences.

Shared music switch checks:

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/shared_music_state.gd --quit-after 1500
```

Checks both directions between main-menu and level Settings, updates to an open panel, saved state, and migration of the earlier main-menu sound mute.
