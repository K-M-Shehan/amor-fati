extends RigidBody3D

var _level: BaseLevel = null
var _blocked_node_id: int = -1
var _last_block_pos: Vector3 = Vector3.ZERO
var _check_timer: float = 0.0
var _check_interval: float = 0.5   # check every 0.5s if box has moved enough
var is_blocking: bool = false   # true only when actively sitting on a node

func _ready() -> void:
	add_to_group("crates")
	# Walk up the tree to find the level
	var node = get_parent()
	while node != null:
		if node is BaseLevel:
			_level = node
			break
		node = node.get_parent()
	# Block the starting node immediately
	if _level != null:
		_last_block_pos = global_position + Vector3(999, 0, 0)  # force first update
		_update_blocked_node()

func _physics_process(delta: float) -> void:
	_check_timer += delta
	if _check_timer < _check_interval:
		return
	_check_timer = 0.0

	if _level == null:
		return

	# Only update if the box has moved more than 1 unit since last block
	if global_position.distance_to(_last_block_pos) < 1.0:
		return

	_update_blocked_node()

func _update_blocked_node() -> void:
	var graph = _level.builder.graph
	var new_node_id = _level.get_closest_node_id(global_position)

	# Nothing changed
	if new_node_id == _blocked_node_id:
		return

	# Restore the previously blocked node
	if _blocked_node_id != -1:
		_restore_node(_blocked_node_id)

	# Block the new node
	_block_node(new_node_id)
	_blocked_node_id = new_node_id
	_last_block_pos = global_position

	is_blocking = true
	_level.recalculate_path()
	print("Crate moved — node %d now blocked" % new_node_id)

func _block_node(node_id: int) -> void:
	var graph = _level.builder.graph
	if not graph.nodes.has(node_id):
		return
	graph.nodes[node_id].blocked = true
	for neighbor_id in graph.nodes[node_id].neighbors.duplicate():
		graph.remove_edge(node_id, neighbor_id)

func _restore_node(node_id: int) -> void:
	var graph = _level.builder.graph
	if not graph.nodes.has(node_id):
		return
	graph.nodes[node_id].blocked = false
	var target_node = graph.nodes[node_id]
	for other_id in graph.nodes:
		if other_id == node_id:
			continue
		var dist = target_node.position.distance_to(graph.nodes[other_id].position)
		if dist < _level.builder.connection_distance:
			graph.add_edge(node_id, other_id)

# Called when the level scene is exited — clean up any blocked node
func _exit_tree() -> void:
	if _blocked_node_id != -1 and _level != null:
		_restore_node(_blocked_node_id)
		is_blocking = false
