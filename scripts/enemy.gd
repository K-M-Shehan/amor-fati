extends CharacterBody3D

var path = []
var speed = 3.0
var player
var rotation_speed = 5.0

func _ready():
	add_to_group("enemies")
	player = get_parent().get_node("Player")
	$KillZone.body_entered.connect(_on_body_entered)

func set_path(p: Array, graph: Graph):
	# only update if new path is different
	if p.size() == 0:
		return

	var new_target = graph.nodes[p[p.size() - 1]].position

	if path.size() > 0:
		var current_target = path[path.size() - 1]
		if new_target.distance_to(current_target) < 1.0:
			return

	path.clear()

	for i in range(p.size()):
		var pos = graph.nodes[p[i]].position

		if i == 0 and global_position.distance_to(pos) < 1.0:
			continue

		path.append(pos)
		
func _on_body_entered(body):
	if body.name == "Player":
		print("Player killed (enemy caught)")
		body.die()

func get_lookahead_target():
	if path.size() == 0:
		return null

	var lookahead_steps = 2  # tweak this (1–3 is good)

	var index = min(lookahead_steps, path.size() - 1)
	return path[index]

func has_line_of_sight() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		player.global_position
	)
	# Exclude this enemy from the raycast
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	# If nothing was hit, or what was hit is the player, we have LOS
	return result.is_empty() or result.collider == player
	
func _physics_process(delta):
	var dist_to_player = global_position.distance_to(player.global_position)
	var target

	# Close/medium range: chase directly if we can see the player
	if dist_to_player < 20.0 and has_line_of_sight():
		target = player.global_position
	# Far away or LOS blocked: follow the nav graph
	else:
		var next_node = get_lookahead_target()
		if next_node != null:
			target = next_node
		else:
			target = player.global_position

	# Movement direction
	var dir = (target - global_position).normalized()

	# Smooth rotation to face movement direction
	if dir.length() > 0.01:
		var target_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

	# Smooth velocity transition to avoid snapping
	velocity = velocity.lerp(dir * speed, 6.0 * delta)
	move_and_slide()

	# Remove passed nodes aggressively to avoid stalling
	while path.size() > 0 and global_position.distance_to(path[0]) < 1.0:
		path.pop_front()
