# `bfs.gd` — Breadth-first search

Location: `scripts/bfs.gd`

Summary
- BFS pathfinder used as alternative to A*; also returns `BFSResult` with path and visited order for visualization.

Usage
- `find_path(start, goal)` or `find_path_detailed(start, goal)` for debug visualizer.

## Code excerpts

Main BFS loop (simplified)
```gdscript
var queue = [start]
var visited = { start: true }
var came_from = { start: -1 }
while queue.size() > 0:
	var current = queue.pop_front()
	if current == goal:
		result.found = true
		result.path = _reconstruct(came_from, current)
		return result
	for neighbor in graph.nodes[current].neighbors:
		if visited.has(neighbor):
			continue
		if graph.nodes[neighbor].blocked:
			continue
		visited[neighbor] = true
		came_from[neighbor] = current
		queue.append(neighbor)
```
