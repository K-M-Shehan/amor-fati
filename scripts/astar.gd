class_name AStarCustom

var graph: Graph

func _init(g: Graph):
	graph = g

func heuristic(a: Vector3, b: Vector3) -> float:
	return a.distance_to(b)

func find_path(start: int, goal: int) -> Array:
	var open = [start]
	var came_from = {}

	var g_score = {}
	var f_score = {}

	for id in graph.nodes.keys():
		g_score[id] = INF
		f_score[id] = INF

	g_score[start] = 0
	f_score[start] = heuristic(graph.nodes[start], graph.nodes[goal])

	while open.size() > 0:
		var current = open[0]

		for n in open:
			if f_score[n] < f_score[current]:
				current = n

		if current == goal:
			return reconstruct(came_from, current)

		open.erase(current)

		for neighbor in graph.edges[current]:
			var base_distance = graph.nodes[current].distance_to(graph.nodes[neighbor])
			var terrain_cost = get_cost(graph.types[neighbor])

			# skip spikes completely
			if terrain_cost == INF:
				continue

			var tentative = g_score[current] + base_distance * terrain_cost

			if tentative < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative
				f_score[neighbor] = tentative + heuristic(graph.nodes[neighbor], graph.nodes[goal])

				if neighbor not in open:
					open.append(neighbor)

	return []

func reconstruct(came_from, current):
	var path = [current]

	while current in came_from:
		current = came_from[current]
		path.insert(0, current)

	return path

func get_cost(tile_type):
	match tile_type:
		Waypoint.TileType.NORMAL:
			return 1.0
		Waypoint.TileType.MUD:
			return 3.0
		Waypoint.TileType.WATER:
			return 2.0
		Waypoint.TileType.SPIKE:
			return INF
	return 1.0
