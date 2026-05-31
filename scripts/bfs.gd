class_name BFS

var graph: Graph

func _init(g: Graph):
	graph = g

# Original return type — still works for enemies
func find_path(start: int, goal: int) -> Array:
	var result = find_path_detailed(start, goal)
	return result.path

# New method — returns full frontier data for the visualizer
func find_path_detailed(start: int, goal: int) -> BFSResult:
	var result = BFSResult.new()

	if not graph.nodes.has(start) or not graph.nodes.has(goal):
		return result

	var queue = [start]
	var visited = { start: true }
	var came_from = { start: -1 }

	result.visited_order.append(start)
	result.parent_map[start] = -1

	while queue.size() > 0:
		var current = queue.pop_front()

		if current == goal:
			result.found = true
			result.path = _reconstruct(came_from, current)
			result.parent_map = came_from
			return result

		for neighbor in graph.nodes[current].neighbors:
			if visited.has(neighbor):
				continue
			if not graph.nodes.has(neighbor):
				continue
			if graph.nodes[neighbor].blocked:
				continue
			visited[neighbor] = true
			came_from[neighbor] = current
			result.visited_order.append(neighbor)
			result.parent_map[neighbor] = current
			queue.append(neighbor)

	result.parent_map = came_from
	return result

func _reconstruct(came_from: Dictionary, current: int) -> Array:
	var path = [current]
	while came_from.has(current) and came_from[current] != -1:
		current = came_from[current]
		path.insert(0, current)
	return path

# Result container
class BFSResult:
	var path: Array         = []
	var visited_order: Array = []
	var parent_map: Dictionary = {}
	var found: bool          = false
