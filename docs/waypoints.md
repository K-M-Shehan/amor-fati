# Waypoints & PathNodes

Waypoints
- Scene script: `scripts/waypoint.gd` (class `Waypoint`).
- Exports: `id` (int), `tile_type` (`NORMAL`, `MUD`, `WATER`, `SPIKE`), `movement_penalty` (float).
- To include a waypoint in the pathfinding graph, assign it to the `waypoints` group in the editor.

PathNode
- Data container: `scripts/path_node.gd` (class `PathNode`). Holds `id`, `position`, `neighbors`, `terrain_cost`, `blocked`, and `terrain_type`.

Usage
- `Graph_builder` scans all nodes in group `waypoints` and calls `graph.add_node(id, position, movement_penalty, tile_type)` to create `PathNode` instances used by `AStarCustom` and `BFS`.

Code excerpts
```gdscript
# waypoint.gd
@export var id: int
@export var tile_type: TileType = TileType.NORMAL
@export var movement_penalty: float = 1.0

# path_node.gd
var id: int
var position: Vector3
var neighbors = []
var terrain_cost: float = 1.0
var blocked: bool = false
var terrain_type:int = Waypoint.TileType.NORMAL
```

Design notes
- Set `movement_penalty` higher for MUD to slow path costs; set `blocked = true` on nodes occupied by crates or puddles to force graph changes.
