extends Node

const SAVE_PATH = "user://progress.cfg"

var furthest_level: int = 1   # 1 through 4
var mouse_sensitivity: float = 0.5
var master_volume: float     = 1.0

func _ready() -> void:
	load_progress()
	# Apply loaded volume immediately
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(master_volume)
	)

func save_progress() -> void:
	var config = ConfigFile.new()
	config.set_value("progress",  "furthest_level",    furthest_level)
	config.set_value("settings",  "mouse_sensitivity",  mouse_sensitivity)
	config.set_value("settings",  "master_volume",      master_volume)
	config.save(SAVE_PATH)

func load_progress() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		furthest_level    = config.get_value("progress", "furthest_level",   1)
		mouse_sensitivity = config.get_value("settings", "mouse_sensitivity", 0.5)
		master_volume     = config.get_value("settings", "master_volume",     1.0)
	else:
		furthest_level = 1   # no save file yet — start from level 1
		mouse_sensitivity = 0.5
		master_volume     = 1.0

func unlock_level(level_number: int) -> void:
	if level_number > furthest_level:
		furthest_level = level_number
		save_progress()

func reset_progress() -> void:
	furthest_level = 1
	save_progress()
