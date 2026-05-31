extends Node3D
class_name DebugVisualizer

enum VisMode {
	OFF,
	GRAPH_ONLY,
	ASTAR_PATH,
	BFS_PATH,
	COMPARE,
	FRONTIER_ASTAR,
	FRONTIER_BFS
}

@export var toggle_key: Key = KEY_F1
@export var node_height_offset: float = 0.4

var _mode: VisMode = VisMode.OFF

var _graph: Graph = null
var _astar_result = null   # AStarCustom.AStarResult
var _bfs_result   = null   # BFS.BFSResult

var _mesh_graph:    MeshInstance3D
var _mesh_astar:    MeshInstance3D
var _mesh_bfs:      MeshInstance3D
var _mesh_frontier: MeshInstance3D

var _mat_edge:           StandardMaterial3D
var _mat_node_normal:    StandardMaterial3D
var _mat_node_mud:       StandardMaterial3D
var _mat_node_water:     StandardMaterial3D
var _mat_node_spike:     StandardMaterial3D
var _mat_astar_path:     StandardMaterial3D
var _mat_bfs_path:       StandardMaterial3D
var _mat_astar_frontier: StandardMaterial3D
var _mat_bfs_frontier:   StandardMaterial3D

var _canvas:      CanvasLayer
var _stats_label: Label

func _ready() -> void:
	_build_materials()
	_build_mesh_nodes()
	_build_hud()
	_refresh_visibility()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == toggle_key:
			_cycle_mode()

#  Public API — called from base_level
func update_data(graph: Graph, astar_result, bfs_result) -> void:
	_graph        = graph
	_astar_result = astar_result
	_bfs_result   = bfs_result
	_redraw()

func set_mode(mode: VisMode) -> void:
	_mode = mode
	_refresh_visibility()
	_redraw()

func get_mode() -> VisMode:
	return _mode

func _cycle_mode() -> void:
	_mode = (_mode + 1) % VisMode.size() as VisMode
	_refresh_visibility()
	_redraw()
	_update_hud()

func _refresh_visibility() -> void:
	_mesh_graph.visible    = _mode != VisMode.OFF
	_mesh_astar.visible    = _mode in [VisMode.ASTAR_PATH, VisMode.COMPARE]
	_mesh_bfs.visible      = _mode in [VisMode.BFS_PATH, VisMode.COMPARE]
	_mesh_frontier.visible = _mode in [VisMode.FRONTIER_ASTAR, VisMode.FRONTIER_BFS, VisMode.COMPARE]
	_canvas.visible        = _mode != VisMode.OFF

func _redraw() -> void:
	if _mode == VisMode.OFF or _graph == null:
		return
	_draw_graph()
	if _astar_result != null:
		_draw_astar()
	if _bfs_result != null:
		_draw_bfs()
	_update_hud()

func _draw_graph() -> void:
	var imesh := ImmediateMesh.new()
	_mesh_graph.mesh = imesh

	# Edges
	imesh.surface_begin(Mesh.PRIMITIVE_LINES, _mat_edge)
	for id in _graph.nodes:
		var node = _graph.nodes[id]
		var from = node.position + Vector3.UP * node_height_offset
		for nid in node.neighbors:
			if not _graph.nodes.has(nid):
				continue
			var to = _graph.nodes[nid].position + Vector3.UP * node_height_offset
			imesh.surface_add_vertex(from)
			imesh.surface_add_vertex(to)
	imesh.surface_end()

	# Node crosses
	for id in _graph.nodes:
		var node = _graph.nodes[id]
		var mat = _mat_for_node(node)
		var p = node.position + Vector3.UP * node_height_offset
		var s: float = 0.35
		imesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
		imesh.surface_add_vertex(p + Vector3(-s, 0, 0))
		imesh.surface_add_vertex(p + Vector3( s, 0, 0))
		imesh.surface_add_vertex(p + Vector3(0, 0, -s))
		imesh.surface_add_vertex(p + Vector3(0, 0,  s))
		imesh.surface_add_vertex(p + Vector3(0, -s, 0))
		imesh.surface_add_vertex(p + Vector3(0,  s, 0))
		imesh.surface_end()

func _draw_astar() -> void:
	var imesh := ImmediateMesh.new()
	_mesh_astar.mesh = imesh

	if _astar_result.found and _astar_result.path.size() > 1:
		imesh.surface_begin(Mesh.PRIMITIVE_LINES, _mat_astar_path)
		for i in range(_astar_result.path.size() - 1):
			var a_id = _astar_result.path[i]
			var b_id = _astar_result.path[i + 1]
			if not _graph.nodes.has(a_id) or not _graph.nodes.has(b_id):
				continue
			var a = _graph.nodes[a_id].position + Vector3.UP * (node_height_offset + 0.25)
			var b = _graph.nodes[b_id].position + Vector3.UP * (node_height_offset + 0.25)
			imesh.surface_add_vertex(a)
			imesh.surface_add_vertex(b)
		imesh.surface_end()

	if _mode in [VisMode.FRONTIER_ASTAR, VisMode.COMPARE]:
		imesh.surface_begin(Mesh.PRIMITIVE_LINES, _mat_astar_frontier)
		for id in _astar_result.parent_map:
			var parent_id = _astar_result.parent_map[id]
			if parent_id == -1 or parent_id == null:
				continue
			if not _graph.nodes.has(id) or not _graph.nodes.has(parent_id):
				continue
			var a = _graph.nodes[parent_id].position + Vector3.UP * node_height_offset
			var b = _graph.nodes[id].position        + Vector3.UP * node_height_offset
			imesh.surface_add_vertex(a)
			imesh.surface_add_vertex(b)
		imesh.surface_end()

func _draw_bfs() -> void:
	var imesh := ImmediateMesh.new()
	_mesh_bfs.mesh = imesh

	if _bfs_result.found and _bfs_result.path.size() > 1:
		imesh.surface_begin(Mesh.PRIMITIVE_LINES, _mat_bfs_path)
		for i in range(_bfs_result.path.size() - 1):
			var a_id = _bfs_result.path[i]
			var b_id = _bfs_result.path[i + 1]
			if not _graph.nodes.has(a_id) or not _graph.nodes.has(b_id):
				continue
			var a = _graph.nodes[a_id].position + Vector3.UP * (node_height_offset + 0.05)
			var b = _graph.nodes[b_id].position + Vector3.UP * (node_height_offset + 0.05)
			imesh.surface_add_vertex(a)
			imesh.surface_add_vertex(b)
		imesh.surface_end()

	if _mode in [VisMode.FRONTIER_BFS, VisMode.COMPARE]:
		imesh.surface_begin(Mesh.PRIMITIVE_LINES, _mat_bfs_frontier)
		for id in _bfs_result.parent_map:
			var parent_id = _bfs_result.parent_map[id]
			if parent_id == -1 or parent_id == null:
				continue
			if not _graph.nodes.has(id) or not _graph.nodes.has(parent_id):
				continue
			var a = _graph.nodes[parent_id].position + Vector3.UP * node_height_offset
			var b = _graph.nodes[id].position        + Vector3.UP * node_height_offset
			imesh.surface_add_vertex(a)
			imesh.surface_add_vertex(b)
		imesh.surface_end()

func _update_hud() -> void:
	if _mode == VisMode.OFF:
		_stats_label.text = ""
		return

	var mode_name = VisMode.keys()[_mode]
	var lines = []
	lines.append("DEBUG VISUALIZER  [F1 cycle]")
	lines.append("Mode: %s" % mode_name)
	lines.append("")

	if _graph != null:
		var edge_count = 0
		for id in _graph.nodes:
			edge_count += _graph.nodes[id].neighbors.size()
		lines.append("Graph nodes : %d" % _graph.nodes.size())
		lines.append("Graph edges : %d" % (edge_count / 2))
		lines.append("")

	if _astar_result != null:
		lines.append("A*  expanded : %d nodes" % _astar_result.visited_order.size())
		lines.append("A*  path len : %d hops" % _astar_result.path.size())
		lines.append("A*  found    : %s" % str(_astar_result.found))
		lines.append("")

	if _bfs_result != null:
		lines.append("BFS expanded : %d nodes" % _bfs_result.visited_order.size())
		lines.append("BFS path len : %d hops" % _bfs_result.path.size())
		lines.append("BFS found    : %s" % str(_bfs_result.found))

	if _astar_result != null and _bfs_result != null and _astar_result.found and _bfs_result.found:
		lines.append("")
		var saved = _bfs_result.visited_order.size() - _astar_result.visited_order.size()
		lines.append("A* saved %d expansions vs BFS" % saved)
		var hop_diff = _bfs_result.path.size() - _astar_result.path.size()
		if hop_diff == 0:
			lines.append("Same path length")
		elif hop_diff > 0:
			lines.append("A* path: %d fewer hops (terrain-aware)" % hop_diff)
		else:
			lines.append("BFS path: %d fewer hops (ignores terrain)" % (-hop_diff))

	_stats_label.text = "\n".join(lines)

func _build_materials() -> void:
	_mat_edge           = _make_mat(Color(0.4, 0.4, 0.4), 0.4)
	_mat_node_normal    = _make_mat(Color(0.8, 0.8, 0.8))
	_mat_node_mud       = _make_mat(Color(0.6, 0.35, 0.1))
	_mat_node_water     = _make_mat(Color(0.1, 0.4, 0.9))
	_mat_node_spike     = _make_mat(Color(0.9, 0.1, 0.1))
	_mat_astar_path     = _make_mat(Color(0.1, 1.0, 0.3), 1.0, true)
	_mat_bfs_path       = _make_mat(Color(1.0, 0.6, 0.0), 1.0, true)
	_mat_astar_frontier = _make_mat(Color(0.1, 0.7, 0.3), 0.25)
	_mat_bfs_frontier   = _make_mat(Color(0.8, 0.4, 0.0), 0.25)

func _make_mat(color: Color, alpha: float = 1.0, emit: bool = false) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(color.r, color.g, color.b, alpha)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emit:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.5
	return m

func _build_mesh_nodes() -> void:
	_mesh_graph    = _make_mesh_instance()
	_mesh_astar    = _make_mesh_instance()
	_mesh_bfs      = _make_mesh_instance()
	_mesh_frontier = _make_mesh_instance()

func _make_mesh_instance() -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi

func _build_hud() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 10
	add_child(_canvas)

	var panel = PanelContainer.new()
	# Anchor to bottom-left corner only
	panel.anchor_left   = 0.0
	panel.anchor_top    = 1.0
	panel.anchor_right  = 0.0
	panel.anchor_bottom = 1.0
	# Position: 12px from left, 12px from bottom, auto width, grows upward
	panel.offset_left   = 12
	panel.offset_right  = 400    # max panel width — wide enough for all text
	panel.offset_top    = -400   # max panel height upward — increase if still clipped
	panel.offset_bottom = -12
	# Let the panel shrink to fit content rather than filling the full rect
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical   = Control.SIZE_SHRINK_END

	var style = StyleBoxFlat.new()
	style.bg_color               = Color(0, 0, 0, 0.6)
	style.corner_radius_top_left     = 6
	style.corner_radius_top_right    = 6
	style.corner_radius_bottom_left  = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left   = 10
	style.content_margin_right  = 10
	style.content_margin_top    = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)

	_stats_label = Label.new()
	_stats_label.add_theme_font_size_override("font_size", 13)
	_stats_label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.9))
	_stats_label.autowrap_mode         = TextServer.AUTOWRAP_OFF
	_stats_label.vertical_alignment    = VERTICAL_ALIGNMENT_TOP
	_stats_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_stats_label.size_flags_vertical   = Control.SIZE_SHRINK_BEGIN
	panel.add_child(_stats_label)
	_canvas.add_child(panel)
	_canvas.visible = false

func _mat_for_node(node: PathNode) -> StandardMaterial3D:
	if node.blocked:
		return _mat_node_spike
	match node.terrain_type:
		Waypoint.TileType.MUD:   return _mat_node_mud
		Waypoint.TileType.WATER: return _mat_node_water
		_:                       return _mat_node_normal
