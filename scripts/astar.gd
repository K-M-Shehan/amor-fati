class_name AStarCustom

enum HeuristicType {
	EUCLIDEAN,    # standard, balanced
	MANHATTAN,    # faster but less accurate in 3D
	WEIGHTED      # aggressive, prioritises getting closer fast
}

var graph: Graph
var heuristic_type: HeuristicType = HeuristicType.EUCLIDEAN

func _init(g: Graph):
	graph = g

func heuristic(a: Vector3, b: Vector3) -> float:
	match heuristic_type:
		HeuristicType.EUCLIDEAN:
			return a.distance_to(b)
		HeuristicType.MANHATTAN:
			return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)
		HeuristicType.WEIGHTED:
			return a.distance_to(b) * 2.0  # greedier, faster but less optimal
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
	f_score[start] = heuristic(graph.nodes[start].position, graph.nodes[goal].position)

	while open.size() > 0:
		var current = open[0]

		for n in open:
			if f_score[n] < f_score[current]:
				current = n

		if current == goal:
			return reconstruct(came_from, current)

		open.erase(current)

		for neighbor in graph.nodes[current].neighbors:
			var base_distance = graph.nodes[current].position.distance_to(graph.nodes[neighbor].position)

			if graph.nodes[neighbor].blocked:
				continue

			var terrain_cost = graph.nodes[neighbor].terrain_cost

			var tentative = g_score[current] + base_distance * terrain_cost

			if tentative < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative
				f_score[neighbor] = tentative + heuristic(graph.nodes[neighbor].position, graph.nodes[goal].position)

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
