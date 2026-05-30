extends Area3D

@export var final_Door: bool = false
var is_open = false

func interact(player):
	if final_Door != true and is_open == false or player.keys_collected >= player.total_keys and final_Door == true and is_open == false:
		open_door()
		is_open = true
	elif is_open == true:
		close_door()
		is_open = false
	else:
		print("Need more keys!")

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
