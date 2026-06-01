# `astar.gd` — A* pathfinding

Location: `scripts/astar.gd`

Summary
- Custom A* implementation that returns `AStarResult` containing path, visited order, parent map, and g_scores for visualization.

Important
- `HeuristicType` enum: `EUCLIDEAN`, `MANHATTAN`, `WEIGHTED`.
- Use `find_path(start, goal)` for path array or `find_path_detailed(start, goal)` for visualization data.

Notes
- `get_cost(tile_type)` maps `Waypoint.TileType` to traversal cost (MUD > WATER > NORMAL). `SPIKE` returns INF.

## Code excerpts

Heuristic selection
```gdscript
func heuristic(a: Vector3, b: Vector3) -> float:
	match heuristic_type:
		HeuristicType.EUCLIDEAN:
			return a.distance_to(b)
		HeuristicType.MANHATTAN:
			return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)
		HeuristicType.WEIGHTED:
			return a.distance_to(b) * 2.0
	return a.distance_to(b)
```

Main loop (simplified)
```gdscript
while open.size() > 0:
	var current = open[0]
	for n in open:
		if f_score[n] < f_score[current]:
			current = n
	if current == goal:
		result.found = true
		result.path = _reconstruct(came_from, current)
		return result
	open.erase(current)
	for neighbor in graph.nodes[current].neighbors:
		if graph.nodes[neighbor].blocked:
			continue
		var tentative = g_score[current] + base_distance * terrain_cost
		if tentative < g_score[neighbor]:
			came_from[neighbor] = current
			g_score[neighbor] = tentative
			f_score[neighbor] = tentative + heuristic(...) 
```
