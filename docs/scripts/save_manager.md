# `save_manager.gd` — Save & settings

Location: `scripts/save_manager.gd`

Summary
- Handles persistence to `user://progress.cfg`. Tracks `furthest_level`, `mouse_sensitivity`, and `master_volume`.

API
- `save_progress()`, `load_progress()`, `unlock_level(level_number)`, `reset_progress()`

## Code excerpts

Saving progress
```gdscript
func save_progress() -> void:
	var config = ConfigFile.new()
	config.set_value("progress", "furthest_level", furthest_level)
	config.set_value("settings", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("settings", "master_volume", master_volume)
	config.save(SAVE_PATH)
```

Loading progress
```gdscript
func load_progress() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		furthest_level = config.get_value("progress", "furthest_level", 1)
		mouse_sensitivity = config.get_value("settings", "mouse_sensitivity", 0.5)
		master_volume = config.get_value("settings", "master_volume", 1.0)
	else:
		furthest_level = 1
		mouse_sensitivity = 0.5
		master_volume = 1.0
```
