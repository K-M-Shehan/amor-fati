# `graph_builder.gd` — Build waypoint graph

Location: `scripts/graph_builder.gd`

Summary
- Scans the scene for nodes in group `waypoints` and builds the `Graph` used by pathfinding systems.
- Export: `connection_distance` to control edge creation.

Notes
- Outputs debug prints of nodes and neighbors when `build_graph()` is called.

## Code excerpts

Building the graph
```gdscript
func build_graph():
	var waypoints = get_tree().get_nodes_in_group("waypoints")
	for w in waypoints:
		graph.add_node(w.id, w.global_position, w.movement_penalty, w.tile_type)
	for a in waypoints:
		for b in waypoints:
			if a == b:
				continue
			if a.global_position.distance_to(b.global_position) < connection_distance:
				graph.add_edge(a.id, b.id)
```
