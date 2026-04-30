extends Node3D

@onready var builder = $Graph_builder
@onready var enemy = $Enemy
@onready var player = $Player

var astar
var bfs

func _ready():
	await get_tree().process_frame

	astar = AStarCustom.new(builder.graph)
	bfs = BFS.new(builder.graph)
	
func recalculate_path():

	var enemy_node = get_closest_node_id(enemy.global_position)
	var player_node = get_closest_node_id(player.global_position)

	var path = astar.find_path(enemy_node, player_node)

	print("CHASE PATH:", path)

	if path.size() > 0:
		enemy.set_path(path, builder.graph)

func recalculate_enemy_path():
	var path = astar.find_path(0,4)

	print("NEW PATH:", path)

	enemy.set_path(path, builder.graph)

func _input(event):

	if event.is_action_pressed("barricade"):
		print("Barricade dropped!")

		builder.graph.remove_edge(1,3)

		recalculate_enemy_path()

func get_closest_node_id(pos: Vector3) -> int:

	var closest_id = -1
	var closest_dist = INF

	for id in builder.graph.nodes:

		var node_pos = builder.graph.nodes[id].position
		var dist = pos.distance_to(node_pos)

		if dist < closest_dist:
			closest_dist = dist
			closest_id = id

	return closest_id

var timer := 0.0
var last_player_pos = Vector3.ZERO

func _physics_process(delta):
	timer += delta

	if timer > 0.5: # recalc every half second
		timer = 0
		if player.global_position.distance_to(last_player_pos) > 2.0:
			recalculate_path()
			last_player_pos = player.global_position
