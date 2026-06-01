# `enemy.gd` — Enemy AI

Location: `scripts/enemy.gd`

Summary
- Enemy AI that activates when the `Player` enters an activation zone, follows paths built from the waypoint graph, performs LOS checks, and animates procedural mesh bone transforms.

Important exports
- `speed` (float), `activation_size` (Vector3), `activation` sound

Key methods
- `_ready()`: connect zones, cache mesh parts, store origin transforms
- `_on_activation_zone_entered(body)`: activates enemy
- `get_terrain_speed()`: adjust movement by waypoint `terrain_type`
- `set_path(p, graph)`: accept node-index path and convert to world positions
- `has_line_of_sight()`: raycast-based LOS with caching
- `_physics_process(delta)`: chooses target (direct player or path lookahead), rotates, moves, prunes path
- `_animate_mesh(delta)`: procedural slight bob/swing animation applied to cached meshes

Notes
- Use `force_graph_path` to force following the graph when obstacles exist.

## Code excerpts

Activation zone setup
```gdscript
var new_shape = BoxShape3D.new()
new_shape.size = activation_size
$ActivationZone/CollisionShape3D.shape = new_shape
await get_tree().process_frame
$ActivationZone.body_entered.connect(_on_activation_zone_entered)
```

Setting path (node indices -> world positions)
```gdscript
func set_path(p: Array, graph: Graph):
	if not is_active or p.size() == 0:
		return
	path.clear()
	for i in range(p.size()):
		var pos = graph.nodes[p[i]].position
		if i == 0 and global_position.distance_to(pos) < 1.0:
			continue
		path.append(pos)
```

Line-of-sight check (raycast)
```gdscript
var space_state = get_world_3d().direct_space_state
var query = PhysicsRayQueryParameters3D.create(global_position, player.global_position)
query.exclude = [self]
var result = space_state.intersect_ray(query)
_los_result = result.is_empty() or result.collider == player
```
