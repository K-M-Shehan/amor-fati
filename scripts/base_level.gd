extends Node3D
class_name BaseLevel

@onready var builder = $Graph_builder
@onready var player = $Player
@onready var spotlight = $Player/Head/Camera3D/Spotlight
var astar: AStarCustom
var bfs: BFS
var timer := 0.0
var last_player_pos = Vector3.ZERO
@export var heuristic_type: AStarCustom.HeuristicType = AStarCustom.HeuristicType.EUCLIDEAN
@export var enable_spot_light = true
@export var enable_debug_visualizer: bool = false

# Visualizer — spawned automatically, no scene edit needed
var _visualizer: DebugVisualizer

func _ready():
	await get_tree().process_frame
	builder.build_graph()
	astar = AStarCustom.new(builder.graph)
	astar.heuristic_type = heuristic_type
	bfs = BFS.new(builder.graph)
	player.level_graph = builder.graph
	spotlight.visible = enable_spot_light
	for e in get_tree().get_nodes_in_group("enemies"):
		e.level_graph = builder.graph
	_setup_visualizer()

func _setup_visualizer() -> void:
	if not enable_debug_visualizer:
		return
	_visualizer = DebugVisualizer.new()
	add_child(_visualizer)

func recalculate_path():
	for e in get_tree().get_nodes_in_group("enemies"):
		var enemy_node = get_closest_node_id(e.global_position)
		var player_node = get_closest_node_id(player.global_position)
		if enemy_node == -1 or player_node == -1:
			continue
		var path = astar.find_path(enemy_node, player_node)
		if path.size() > 0:
			e.set_path(path, builder.graph)
	# Feed both results to the visualizer (only does work if not OFF)
	_update_visualizer()

func _update_visualizer() -> void:
	if _visualizer == null:
		return
	if _visualizer.get_mode() == DebugVisualizer.VisMode.OFF:
		return

	var enemy_node  = -1
	var player_node = get_closest_node_id(player.global_position)

	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		enemy_node = get_closest_node_id(enemies[0].global_position)

	if enemy_node == -1 or player_node == -1:
		return

	var astar_result = astar.find_path_detailed(enemy_node, player_node)
	var bfs_result   = bfs.find_path_detailed(enemy_node, player_node)
	_visualizer.update_data(builder.graph, astar_result, bfs_result)

func get_closest_node_id(pos: Vector3) -> int:
	var closest_id = -1
	var closest_dist = INF
	for id in builder.graph.nodes.keys():
		var dist = pos.distance_to(builder.graph.nodes[id].position)
		if dist < closest_dist:
			closest_dist = dist
			closest_id = id
	return closest_id

# Overridden by levels that use barricades (e.g. level3.gd)
func trigger_barricade(_world_pos: Vector3) -> void:
	pass

func _physics_process(delta):
	timer += delta
	if timer > 1.0:
		timer = 0
		if player.global_position.distance_to(last_player_pos) > 2.0:
			recalculate_path()
			last_player_pos = player.global_position
