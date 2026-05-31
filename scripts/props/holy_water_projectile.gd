extends Node3D

var velocity: Vector3 = Vector3.ZERO
var gravity: float = 12.0
var _landed: bool = false

func launch(direction: Vector3, force: float = 10.0) -> void:
	velocity = direction * force + Vector3.UP * 4.0

func _physics_process(delta: float) -> void:
	if _landed:
		return
	velocity.y -= gravity * delta
	global_position += velocity * delta

	# Check for ground hit using a downward raycast
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * 0.3
	)
	var result = space.intersect_ray(query)
	if result:
		_land(result.position)

func _land(pos: Vector3) -> void:
	_landed = true
	# Tell the level to sever edges near this position
	var level = _find_level()
	if level and level.has_method("trigger_barricade"):
		level.trigger_barricade(pos)
	queue_free()

func _find_level() -> Node:
	var node = get_parent()
	while node != null:
		if node is BaseLevel:
			return node
		node = node.get_parent()
	return null
