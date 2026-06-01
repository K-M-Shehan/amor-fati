# `holy_water_puddle.gd` — Area effect that blocks nodes

Location: `scripts/props/holy_water_puddle.gd`

Summary
- When spawned, collects nearby graph nodes within `blast_radius`, marks them `blocked`, removes their edges, and forces `level.recalculate_path()`. After `duration`, restores edges and unblocks nodes.

Code excerpt
```gdscript
func setup(node_id: int, lvl: BaseLevel, radius: float = 8.0) -> void:
    level = lvl
    blast_radius = radius
    _collect_nodes_in_radius(lvl.builder.graph, node_id)
    _apply_block()

func _apply_block() -> void:
    var graph = level.builder.graph
    for node_id in affected_node_ids:
        graph.nodes[node_id].blocked = true
        for neighbor_id in graph.nodes[node_id].neighbors.duplicate():
            graph.remove_edge(node_id, neighbor_id)
    level.recalculate_path()
```
