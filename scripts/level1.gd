extends BaseLevel

func _input(event):
	if event.is_action_pressed("barricade"):
		builder.graph.remove_edge(1, 3)
		recalculate_path()
