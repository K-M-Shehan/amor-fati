class_name Graph

var nodes = {}  # id -> Vector3
var edges = {}  # id -> Array[int] neighbors
var types = {}  # id -> tile_type

func add_node(id: int, pos: Vector3, tile_type):
	nodes[id] = pos
	edges[id] = []
	types[id] = tile_type

func add_edge(a: int, b: int):
	if b not in edges[a]:
		edges[a].append(b)
	if a not in edges[b]:
		edges[b].append(a)
