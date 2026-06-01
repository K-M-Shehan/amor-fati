# `graph.gd` — Graph container

Location: `scripts/graph.gd`

Summary
- Lightweight container for `PathNode` objects. Methods: `add_node`, `add_edge`, `remove_edge`.

Notes
- Nodes store `position`, `terrain_cost`, `terrain_type`, and `neighbors`.

## Code excerpts

Adding a node
```gdscript
func add_node(id,pos,cost,t_type):
	var node = PathNode.new()
	node.id = id
	node.position = pos
	node.terrain_cost = cost
	node.terrain_type = t_type
	nodes[id] = node
```

Connecting two nodes
```gdscript
func add_edge(a,b):
	if b not in nodes[a].neighbors:
		nodes[a].neighbors.append(b)
	if a not in nodes[b].neighbors:
		nodes[b].neighbors.append(a)
```
