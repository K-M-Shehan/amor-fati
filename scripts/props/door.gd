extends Area3D

@export var keys_needed: int = 0
var is_open = false

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

func close_door():
	var tween = create_tween()
	tween.tween_property($Door/Hinge, "rotation_degrees:y", 0, 1.0)
