extends CharacterBody3D

var path = []
var speed = 3.0

func set_path(p: Array, graph: Graph):
	path.clear()

	for id in p:
		path.append(graph.nodes[id])

func _physics_process(delta):
	if path.size() == 0:
		return

	var target = path[0]
	var dir = (target - global_position).normalized()

	velocity = dir * speed
	move_and_slide()

	if global_position.distance_to(target) < 0.3:
		path.pop_front()
