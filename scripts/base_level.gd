extends Node3D
class_name BaseLevel

@onready var builder = $Graph_builder
@onready var player = $Player
var astar
var bfs
var timer := 0.0
var last_player_pos = Vector3.ZERO
@export var keys_required: int = 2

func _ready():
	await get_tree().process_frame
	builder.build_graph()
	astar = AStarCustom.new(builder.graph)
	bfs = BFS.new(builder.graph)
	player.level_graph = builder.graph
	player.total_keys = keys_required
	for e in get_tree().get_nodes_in_group("enemies"):
		e.level_graph = builder.graph

func recalculate_path():
	for e in get_tree().get_nodes_in_group("enemies"):
		var enemy_node = get_closest_node_id(e.global_position)
		var player_node = get_closest_node_id(player.global_position)
		if enemy_node == -1 or player_node == -1:
			continue
		var path = astar.find_path(enemy_node, player_node)
		if path.size() > 0:
			e.set_path(path, builder.graph)

func get_closest_node_id(pos: Vector3) -> int:
	var closest_id = -1
	var closest_dist = INF
	for id in builder.graph.nodes.keys():
		var dist = pos.distance_to(builder.graph.nodes[id].position)
		if dist < closest_dist:
			closest_dist = dist
			closest_id = id
	return closest_id

func _physics_process(delta):
	timer += delta
	if timer > 1.0:
		timer = 0
		if player.global_position.distance_to(last_player_pos) > 2.0:
			recalculate_path()
			last_player_pos = player.global_position
