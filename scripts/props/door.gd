extends Area3D

func interact(player):
	if player.keys_collected >= player.total_keys:
		open_door()
	else:
		print("Need more keys!")

func get_interaction_text():
	return "Open door"

func open_door():
	var tween = create_tween()
	tween.tween_property($Door/Hinge, "rotation_degrees:y", -90, 1.0)
