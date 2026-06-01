# `base_level.gd` — Level orchestrator

Location: `scripts/base_level.gd`

Summary
- Builds the waypoint graph, constructs `AStarCustom` and `BFS` instances, assigns `level_graph` to `player` and enemies, and periodically recalculates enemy paths.

Key methods
- `_ready()`: calls `builder.build_graph()`, initializes pathfinders, assigns graphs
- `recalculate_path()`: computes paths from enemies to player and updates enemies
- `get_closest_unblocked_node_id(pos)`: helper skipping blocked nodes
- `trigger_barricade(world_pos)`: intended to be overridden by levels that spawn barricades

Debugging
- Toggle `enable_debug_visualizer` to spawn a `DebugVisualizer` for pathfinding diagnostics.

## Code excerpts

Recalculate enemy paths
```gdscript
func recalculate_path() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		var enemy_node  = get_closest_node_id(e.global_position)
		var player_node = get_closest_unblocked_node_id(player.global_position)
		if enemy_node == -1 or player_node == -1:
			continue
		var path = astar.find_path(enemy_node, player_node)
		if path.size() > 0:
			e.set_path(path, builder.graph)
	_update_visualizer()
```

Get closest unblocked node
```gdscript
func get_closest_unblocked_node_id(pos: Vector3) -> int:
	var closest_id = -1
	var closest_dist = INF
	for id in builder.graph.nodes.keys():
		var node = builder.graph.nodes[id]
		if node.blocked:
			continue
		var dist = pos.distance_to(node.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_id = id
	return closest_id
```
