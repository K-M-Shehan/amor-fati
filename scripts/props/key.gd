extends Area3D

func interact(player):
	player.collect_key()
	queue_free()

func get_interaction_text():
	return "Pick up key"
