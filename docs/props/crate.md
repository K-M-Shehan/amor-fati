# `crate.gd` — Physics crate that blocks graph nodes

Location: `scripts/props/crate.gd`

Summary
- `RigidBody3D` that monitors its position and marks the nearest graph node as `blocked` when resting on it. When moved, it restores previous node and blocks the new one, calling `level.recalculate_path()`.

Key behavior
- On `_ready()` it finds `BaseLevel` and waits two frames for graph to be built, then calls `_update_blocked_node()`.
- On movement, it restores old blocked node and removes edges for the new blocked node to force path recalculation.

Code excerpt
```gdscript
func _block_node(node_id: int) -> void:
    var graph = _level.builder.graph
    graph.nodes[node_id].blocked = true
    for neighbor_id in graph.nodes[node_id].neighbors.duplicate():
        graph.remove_edge(node_id, neighbor_id)
```
