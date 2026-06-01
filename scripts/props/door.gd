extends Area3D

@export var keys_needed: int = 0
@export var sound_open: AudioStream
@export var sound_close: AudioStream

var is_open = false

@onready var _door_sound = $DoorSound

func interact(player):
	if player.keys_collected >= keys_needed and is_open == false:
		open_door()
		is_open = true
	elif is_open == true:
		close_door()
		is_open = false
	else:
		print("Need %d more keys!" % (keys_needed - player.keys_collected))

func get_interaction_text():
	if is_open == false:
		return "Open door"
	else:
		return "Close door"

func open_door():
	var tween = create_tween()
	tween.tween_property($Door/Hinge, "rotation_degrees:y", -90, 1.0)
	_play_sound(sound_open)

func close_door():
	var tween = create_tween()
	tween.tween_property($Door/Hinge, "rotation_degrees:y", 0, 0.5)
	_play_sound(sound_close)

func _play_sound(stream: AudioStream) -> void:
	if _door_sound == null or stream == null:
		return
	_door_sound.stream = stream
	_door_sound.play()
