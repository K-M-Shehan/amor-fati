class_name Graph

var nodes = {}

func add_node(id,pos,cost,t_type):
	var node = PathNode.new()

	node.id=id
	node.position=pos
	node.terrain_cost=cost
	node.terrain_type=t_type

	nodes[id]=node


func add_edge(a,b):

	if b not in nodes[a].neighbors:
		nodes[a].neighbors.append(b)

	if a not in nodes[b].neighbors:
		nodes[b].neighbors.append(a)
