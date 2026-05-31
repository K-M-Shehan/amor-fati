extends Node3D

var affected_node_id: int = -1
var affected_node_ids: Array = []   # to store multiple nodes
var level: BaseLevel = null
var duration: float = 10.0
var blast_radius: float = 8.0       # could tune in inspector
var _timer: float = 0.0
var _applied: bool = false

func setup(node_id: int, lvl: BaseLevel, radius: float = 8.0) -> void:
	level = lvl
	blast_radius = radius
	_collect_nodes_in_radius(lvl.builder.graph, node_id)
	_apply_block()
	_start_visual()

func _collect_nodes_in_radius(graph: Graph, origin_id: int) -> void:
	if not graph.nodes.has(origin_id):
		return
	var origin_pos = graph.nodes[origin_id].position
	for id in graph.nodes:
		var dist = graph.nodes[id].position.distance_to(origin_pos)
		if dist <= blast_radius:
			affected_node_ids.append(id)

func _apply_block() -> void:
	if level == null or affected_node_ids.is_empty():
		return
	var graph = level.builder.graph
	for node_id in affected_node_ids:
		if not graph.nodes.has(node_id):
			continue
		graph.nodes[node_id].blocked = true
		for neighbor_id in graph.nodes[node_id].neighbors.duplicate():
			graph.remove_edge(node_id, neighbor_id)
	_applied = true
	add_to_group("holy_water_puddles")

	level.recalculate_path()
	
func _restore_block() -> void:
	if not _applied or level == null:
		return
	var graph = level.builder.graph
	for node_id in affected_node_ids:
		if not graph.nodes.has(node_id):
			continue
		graph.nodes[node_id].blocked = false
		var target_node = graph.nodes[node_id]
		for other_id in graph.nodes:
			if other_id == node_id:
				continue
			var dist = target_node.position.distance_to(graph.nodes[other_id].position)
			if dist < level.builder.connection_distance:
				graph.add_edge(node_id, other_id)

	level.recalculate_path()

func _start_visual() -> void:
	# Glowing blue puddle ring drawn with ImmediateMesh
	var mi = MeshInstance3D.new()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

	var imesh = ImmediateMesh.new()
	mi.mesh = imesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.5, 1.0, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.5, 1.0)
	mat.emission_energy_multiplier = 1.2

	# Draw a filled circle using triangle fan approximation with line loop
	var radius: float = blast_radius
	var steps: int = 24
	imesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	for i in range(steps):
		var angle_a = (float(i) / steps) * TAU
		var angle_b = (float(i + 1) / steps) * TAU
		imesh.surface_add_vertex(Vector3(cos(angle_a) * radius, 0.05, sin(angle_a) * radius))
		imesh.surface_add_vertex(Vector3(cos(angle_b) * radius, 0.05, sin(angle_b) * radius))
	imesh.surface_end()

func _physics_process(delta: float) -> void:
	_timer += delta
	# Pulse the scale slightly for visual feedback
	var pulse = 1.0 + sin(_timer * 3.0) * 0.05
	scale = Vector3(pulse, 1.0, pulse)

	if _timer >= duration:
		_restore_block()
		queue_free()
