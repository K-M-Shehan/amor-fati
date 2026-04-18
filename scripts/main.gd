extends Node3D

@onready var builder = $Graph_builder
@onready var enemy = $Enemy

var astar

func _ready():
	await get_tree().process_frame

	astar = AStarCustom.new(builder.graph)

	var path = astar.find_path(0, 4)

	if path.size() > 0:
		print("PATH:", path)
		print("START POS:", builder.graph.nodes[path[0]])
		enemy.set_path(path, builder.graph)
	else:
		print("No path found!")
