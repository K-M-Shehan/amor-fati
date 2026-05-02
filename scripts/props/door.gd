extends Area3D

func interact(player):
	if player.has_key:
		print("Door opened!")
		open_door()
	else:
		print("Door is locked!")

func get_interaction_text():
	return "Open door"

func open_door():
	# simple version (will animate later)
	visible = false
