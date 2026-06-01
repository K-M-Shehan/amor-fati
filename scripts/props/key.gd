extends Area3D

@export var pickup_sound: AudioStream
@onready var _sound: AudioStreamPlayer3D = $KeyPickupSound

func interact(player):
	player.collect_key()
	
	if pickup_sound:
		_sound.stream = pickup_sound
		_sound.play()

	# delay deletion so sound can play
	await get_tree().create_timer(0.3).timeout
	queue_free()

func get_interaction_text():
	return "Pick up key"
