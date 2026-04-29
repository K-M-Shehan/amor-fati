extends Node3D

@onready var builder = $Graph_builder
@onready var enemy = $Enemy

var astar
var bfs

func _ready():
	await get_tree().process_frame

	astar = AStarCustom.new(builder.graph)
	
	bfs = BFS.new(builder.graph)

	var path = astar.find_path(0, 4)
	
	var bfs_path = bfs.find_path(0, 4)

	print("A* PATH:", path)
	print("BFS PATH:", bfs_path)

	if path.size() > 0:
		print("PATH:", path)
		print("START POS:", builder.graph.nodes[path[0]].position)
		enemy.set_path(path, builder.graph)
	else:
		print("No path found!")

func recalculate_enemy_path():
	var path = astar.find_path(0,4)

	print("NEW PATH:", path)

	enemy.set_path(path, builder.graph)

func _input(event):

	if event.is_action_pressed("ui_accept"):
		print("Barricade dropped!")

		builder.graph.remove_edge(1,3)

		recalculate_enemy_path()
