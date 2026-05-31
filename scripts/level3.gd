extends BaseLevel

const MAX_FLASKS: int = 3
var flasks_remaining: int = MAX_FLASKS

# UI
var _flask_label: Label
var _canvas: CanvasLayer

func _ready() -> void:
	super._ready()
	_build_flask_ui()

func _build_flask_ui() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 5
	add_child(_canvas)

	_flask_label = Label.new()
	_flask_label.add_theme_font_size_override("font_size", 16)
	_flask_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	_flask_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_flask_label.position = Vector2(16, 30)
	_canvas.add_child(_flask_label)
	_update_flask_ui()

func _update_flask_ui() -> void:
	var icons = "[ ]".repeat(MAX_FLASKS - flasks_remaining) 
	var filled = "[W]".repeat(flasks_remaining)
	_flask_label.text = "Holy Water: " + filled + icons

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_holy_water"):
		_throw_flask()

func _throw_flask() -> void:
	if flasks_remaining <= 0:
		return

	flasks_remaining -= 1
	_update_flask_ui()

	# Spawn the projectile at the player's position
	var projectile = Node3D.new()
	projectile.set_script(
		load("res://scripts/props/holy_water_projectile.gd")
	)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = player.global_position + Vector3.UP * 1.2

	# Throw in the direction the player is facing
	var cam = player.get_node("Head/Camera3D")
	var throw_dir = -cam.global_transform.basis.z
	projectile.launch(throw_dir, 10.0)

# Called by holy_water_projectile when it lands
func trigger_barricade(world_pos: Vector3) -> void:
	var node_id = get_closest_node_id(world_pos)
	if node_id == -1:
		return

	# Spawn the puddle at the landing position
	var puddle_script = load("res://scripts/props/holy_water_puddle.gd")
	var puddle = Node3D.new()
	puddle.set_script(puddle_script)
	add_child(puddle)
	puddle.global_position = Vector3(world_pos.x, world_pos.y, world_pos.z)
	puddle.setup(node_id, self, 8.0)

func recalculate_path() -> void:
	var crates = get_tree().get_nodes_in_group("crates")
	var puddles = get_tree().get_nodes_in_group("holy_water_puddles")
	
	# Any active blocker in the scene forces graph-only pathfinding
	var any_blocking = false
	for crate in crates:
		if crate.is_blocking:
			any_blocking = true
			break
	if puddles.size() > 0:
		any_blocking = true

	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.force_graph_path = any_blocking

	super.recalculate_path()
