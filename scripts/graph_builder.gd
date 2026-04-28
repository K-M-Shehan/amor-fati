extends Node

@export var connection_distance := 15.0

var graph = Graph.new()

func _ready():
	build_graph()

func build_graph():
	var waypoints = get_tree().get_nodes_in_group("waypoints")

	# add nodes
	for w in waypoints:
		graph.add_node(w.id, w.global_position, w.movement_penalty, w.tile_type)

	# connect nodes
	for a in waypoints:
		for b in waypoints:
			if a == b:
				continue

			if a.global_position.distance_to(b.global_position) < connection_distance:
				graph.add_edge(a.id, b.id)

	print("Graph built:")
	for id in graph.nodes:
		var n = graph.nodes[id]
		print(
			id,
			" pos=", n.position,
			" cost=", n.terrain_cost,
			" neighbors=", n.neighbors
		)
	for id in graph.nodes:
		print(id, " -> ", graph.nodes[id].neighbors)
