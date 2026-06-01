# `debug_visualizer.gd` — Pathfinding visual debugging

Location: `scripts/debug_visualizer.gd`

Summary
- Provides several visualization modes (graph edges/nodes, A* path, BFS path, frontier comparisons) toggled with `toggle_key` (default `F1`).
- Renders using `ImmediateMesh` and draws edges, node crosses, paths, and frontier parent links.

Modes
- `OFF`, `GRAPH_ONLY`, `ASTAR_PATH`, `BFS_PATH`, `COMPARE`, `FRONTIER_ASTAR`, `FRONTIER_BFS`.

Integration
- `BaseLevel` calls `update_data(builder.graph, astar_result, bfs_result)` to feed results each recalculation. Toggle `enable_debug_visualizer = true` on the level to spawn the visualizer.

Code excerpts
```gdscript
func update_data(graph: Graph, astar_result, bfs_result) -> void:
    _graph = graph
    _astar_result = astar_result
    _bfs_result = bfs_result
    _redraw()

func _draw_graph() -> void:
    var imesh := ImmediateMesh.new()
    _mesh_graph.mesh = imesh
    imesh.surface_begin(Mesh.PRIMITIVE_LINES, _mat_edge)
    for id in _graph.nodes:
        var node = _graph.nodes[id]
        var from = node.position + Vector3.UP * node_height_offset
        for nid in node.neighbors:
            var to = _graph.nodes[nid].position + Vector3.UP * node_height_offset
            imesh.surface_add_vertex(from)
            imesh.surface_add_vertex(to)
    imesh.surface_end()
```
