class_name BFS

var graph: Graph

func _init(g:Graph):
	graph = g


func find_path(start:int, goal:int) -> Array:

	var queue = [start]
	var visited = {}
	var came_from = {}

	visited[start] = true

	while queue.size() > 0:

		var current = queue.pop_front()

		if current == goal:
			return reconstruct(came_from,current)

		for neighbor in graph.nodes[current].neighbors:

			if neighbor not in visited:

				visited[neighbor]=true
				came_from[neighbor]=current
				queue.append(neighbor)

	return []


func reconstruct(came_from,current):

	var path=[current]

	while current in came_from:
		current = came_from[current]
		path.insert(0,current)

	return path
