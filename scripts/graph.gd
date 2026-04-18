class_name Graph

var nodes = {}  # id -> Vector3
var edges = {}  # id -> Array[int]

func add_node(id: int, pos: Vector3):
	nodes[id] = pos
	edges[id] = []

func add_edge(a: int, b: int):
	if b not in edges[a]:
		edges[a].append(b)
	if a not in edges[b]:
		edges[b].append(a)
