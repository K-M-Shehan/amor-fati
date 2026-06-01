extends CharacterBody3D

var level_graph: Graph = null
var path = []
@export var speed: float = 3.0
var player
var rotation_speed = 5.0
var is_active: bool = false # enemy starts idle
@export var activation_size: Vector3 = Vector3(10.0, 5.0, 1.0)
var force_graph_path: bool = false
var has_activated := false

@onready var _activation_sound = $ActivationSound

# Procedural animation
var _bob_timer: float = 0.0
var _bob_speed: float = 4.0
var _current_speed_length: float = 0.0
var _origins: Dictionary = {}

# Torso + Head
var _torso:      MeshInstance3D = null
var _head:       MeshInstance3D = null

# Shoulders
var _shoulder_l: MeshInstance3D = null
var _shoulder_r: MeshInstance3D = null

# Upper Arms
var _upper_arm_1l: MeshInstance3D = null
var _upper_arm_1r: MeshInstance3D = null
var _upper_arm_2l: MeshInstance3D = null
var _upper_arm_2r: MeshInstance3D = null

# Lower Arms
var _lower_arm_l: MeshInstance3D = null
var _lower_arm_r: MeshInstance3D = null

# Fingers Left
var _finger_1l: MeshInstance3D = null
var _finger_2l: MeshInstance3D = null
var _finger_3l: MeshInstance3D = null

# Fingers Right
var _finger_1r: MeshInstance3D = null
var _finger_2r: MeshInstance3D = null
var _finger_3r: MeshInstance3D = null

# Legs
var _thigh_l:     MeshInstance3D = null
var _thigh_r:     MeshInstance3D = null
var _lower_leg_l: MeshInstance3D = null
var _lower_leg_r: MeshInstance3D = null
var _foot_l:      MeshInstance3D = null
var _foot_r:      MeshInstance3D = null

func _ready():
	add_to_group("enemies")
	player = get_parent().get_node("Player")
	$KillZone.body_entered.connect(_on_body_entered)
	# set the box size from the export var
	# duplicate the shape so each enemy has its own independent resource
	var new_shape = BoxShape3D.new()
	new_shape.size = activation_size
	$ActivationZone/CollisionShape3D.shape = new_shape  # ← assign the new independent shape
	# delay connecting activation zone until next frame
	await get_tree().process_frame
	$ActivationZone.body_entered.connect(_on_activation_zone_entered)
	
	var golem = get_node_or_null("golem")
	if golem != null:
		_torso        = golem.get_node_or_null("Torso")
		_head         = golem.get_node_or_null("Head")
		_shoulder_l   = golem.get_node_or_null("ShoulderL")
		_shoulder_r   = golem.get_node_or_null("ShoulderR")
		_upper_arm_1l = golem.get_node_or_null("UpperArm1L")
		_upper_arm_1r = golem.get_node_or_null("UpperArm1R")
		_upper_arm_2l = golem.get_node_or_null("UpperArm2L")
		_upper_arm_2r = golem.get_node_or_null("UpperArm2R")
		_lower_arm_l  = golem.get_node_or_null("LowerArmL")
		_lower_arm_r  = golem.get_node_or_null("LowerArmR")
		_finger_1l    = golem.get_node_or_null("Finger1L")
		_finger_1r    = golem.get_node_or_null("Finger1R")
		_finger_2l    = golem.get_node_or_null("Finger2L")
		_finger_2r    = golem.get_node_or_null("Finger2R")
		_finger_3l    = golem.get_node_or_null("Finger3L")
		_finger_3r    = golem.get_node_or_null("Finger3R")
		_thigh_l      = golem.get_node_or_null("ThighL")
		_thigh_r      = golem.get_node_or_null("ThighR")
		_lower_leg_l  = golem.get_node_or_null("LowerLegL")
		_lower_leg_r  = golem.get_node_or_null("LowerLegR")
		_foot_l       = golem.get_node_or_null("FootL")
		_foot_r       = golem.get_node_or_null("FootR")

		# Save origin transform for every mesh
		for pair in [
			["Torso", _torso], ["Head", _head],
			["ShoulderL", _shoulder_l], ["ShoulderR", _shoulder_r],
			["UpperArm1L", _upper_arm_1l], ["UpperArm1R", _upper_arm_1r],
			["UpperArm2L", _upper_arm_2l], ["UpperArm2R", _upper_arm_2r],
			["LowerArmL", _lower_arm_l],   ["LowerArmR", _lower_arm_r],
			["Finger1L", _finger_1l], ["Finger1R", _finger_1r],
			["Finger2L", _finger_2l], ["Finger2R", _finger_2r],
			["Finger3L", _finger_3l], ["Finger3R", _finger_3r],
			["ThighL", _thigh_l],     ["ThighR", _thigh_r],
			["LowerLegL", _lower_leg_l], ["LowerLegR", _lower_leg_r],
			["FootL", _foot_l],       ["FootR", _foot_r]
		]:
			if pair[1] != null:
				_origins[pair[0]] = {
					"rot": pair[1].rotation,
					"pos": pair[1].position
				}
			else:
				push_warning("Enemy: could not find mesh '%s'" % pair[0])
	else:
		push_warning("Enemy: could not find golem node")
	
func _on_activation_zone_entered(body):
	if has_activated:
		return

	if body.name != "Player":
		return

	has_activated = true
	is_active = true

	if _activation_sound:
		_activation_sound.play()

	print("Enemy activated!")

func get_terrain_speed() -> float:
	if level_graph == null:
		return speed
	for id in level_graph.nodes:
		var node = level_graph.nodes[id]
		if global_position.distance_to(node.position) < 8.0:
			match node.terrain_type:
				Waypoint.TileType.MUD:
					return speed * 0.4
				Waypoint.TileType.WATER:
					return speed * 0.65
	return speed
	
func set_path(p: Array, graph: Graph):
	if not is_active:  # ignores inactive enemies but still does work
		return
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

var _los_timer: float = 0.0
var _los_result: bool = false

func has_line_of_sight() -> bool:
	_los_timer -= get_physics_process_delta_time()
	if _los_timer <= 0.0:
		_los_timer = 0.1  # check 10 times per second instead of 60
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position, player.global_position)
		# Exclude this enemy from the raycast
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		# If nothing was hit, or what was hit is the player, we have LOS
		_los_result = result.is_empty() or result.collider == player
	return _los_result
	
func _animate_mesh(delta: float) -> void:
	_current_speed_length = lerp(_current_speed_length, velocity.length(), 8.0 * delta)

	var move_blend = clamp(_current_speed_length / speed, 0.0, 1.0)

	# smoother walking speed
	if _current_speed_length > 0.15:
		_bob_timer += delta * 4.0 * lerp(0.6, 1.0, move_blend)
	else:
		_bob_timer = lerp(_bob_timer, 0.0, 4.0 * delta)

	# gait cycles
	var left_cycle  = sin(_bob_timer)
	var right_cycle = sin(_bob_timer + PI)

	# delayed cycles for secondary motion
	var left_delay  = sin(_bob_timer + 0.35)
	var right_delay = sin(_bob_timer + PI + 0.35)

	# torso inertia
	var torso_cycle = sin(_bob_timer - 0.18)

	# opposite arm swing
	var arm_l  = -left_cycle
	var arm_r  = -right_cycle
	var arm_l2 = -left_delay
	var arm_r2 = -right_delay

	# helpers
	var apply_rot = func(
		mesh: MeshInstance3D,
		key: String,
		axis: String,
		value: float
	) -> void:
		if mesh == null or not _origins.has(key):
			return

		var target: Vector3 = _origins[key]["rot"]

		match axis:
			"x":
				target.x += value
			"y":
				target.y += value
			"z":
				target.z += value

		mesh.rotation = mesh.rotation.lerp(target, 12.0 * delta)

	var apply_y = func(
		mesh: MeshInstance3D,
		key: String,
		offset: float
	) -> void:
		if mesh == null or not _origins.has(key):
			return

		var origin_y: float = _origins[key]["pos"].y

		mesh.position.y = lerp(
			mesh.position.y,
			origin_y + offset,
			10.0 * delta
		)

	# TORSO + HEAD
	# subtle body bounce
	apply_y.call(
		_torso,
		"Torso",
		-abs(sin(_bob_timer * 2.0)) * 0.025 * move_blend
	)

	# slight forward lean
	apply_rot.call(
		_torso,
		"Torso",
		"z",
		0.03 * move_blend
	)

	# subtle hip sway
	apply_rot.call(
		_torso,
		"Torso",
		"y",
		torso_cycle * 0.025 * move_blend
	)

	# head compensates torso movement
	apply_rot.call(
		_head,
		"Head",
		"y",
		-torso_cycle * 0.015 * move_blend
	)

	# LEFT LEG

	# thigh swing
	apply_rot.call(
		_thigh_l,
		"ThighL",
		"x",
		left_cycle * 0.20 * move_blend
	)

	# knee bends mainly during backward phase
	apply_rot.call(
		_lower_leg_l,
		"LowerLegL",
		"x",
		max(0.0, -left_cycle) * 0.32 * move_blend
	)

	# foot tries to stay flatter
	apply_rot.call(
		_foot_l,
		"FootL",
		"x",
		clamp(-left_cycle * 0.18, -0.08, 0.12) * move_blend
	)

	# RIGHT LEG
	apply_rot.call(
		_thigh_r,
		"ThighR",
		"x",
		-right_cycle * 0.20 * move_blend
	)

	apply_rot.call(
		_lower_leg_r,
		"LowerLegR",
		"x",
		max(0.0, -right_cycle) * 0.32 * move_blend
	)

	apply_rot.call(
		_foot_r,
		"FootR",
		"x",
		-clamp(-right_cycle * 0.18, -0.08, 0.12) * move_blend
	)

	# LEFT ARM
	apply_rot.call(
		_shoulder_l,
		"ShoulderL",
		"x",
		arm_l * 0.10 * move_blend
	)

	apply_rot.call(
		_upper_arm_1l,
		"UpperArm1L",
		"x",
		arm_l * 0.22 * move_blend
	)

	apply_rot.call(
		_upper_arm_2l,
		"UpperArm2L",
		"x",
		arm_l * 0.16 * move_blend
	)

	apply_rot.call(
		_lower_arm_l,
		"LowerArmL",
		"x",
		arm_l2 * 0.10 * move_blend
	)

	# slight finger curl
	var curl_l = (arm_l * 0.5 + 0.5) * 0.08 * move_blend

	apply_rot.call(_finger_1l, "Finger1L", "x", curl_l)
	apply_rot.call(_finger_2l, "Finger2L", "x", curl_l * 0.7)
	apply_rot.call(_finger_3l, "Finger3L", "x", curl_l * 0.5)

	# RIGHT ARM
	apply_rot.call(
		_shoulder_r,
		"ShoulderR",
		"x",
		-arm_r * 0.10 * move_blend
	)

	apply_rot.call(
		_upper_arm_1r,
		"UpperArm1R",
		"x",
		-arm_r * 0.22 * move_blend
	)

	apply_rot.call(
		_upper_arm_2r,
		"UpperArm2R",
		"x",
		-arm_r * 0.16 * move_blend
	)

	apply_rot.call(
		_lower_arm_r,
		"LowerArmR",
		"x",
		-arm_r2 * 0.10 * move_blend
	)

	var curl_r = (arm_r * 0.5 + 0.5) * 0.08 * move_blend

	apply_rot.call(_finger_1r, "Finger1R", "x", curl_r)
	apply_rot.call(_finger_2r, "Finger2R", "x", curl_r * 0.7)
	apply_rot.call(_finger_3r, "Finger3R", "x", curl_r * 0.5)

func _physics_process(delta):
	if not is_active:	# do nothing if not yet activated
		return
	
	var dist_to_player = global_position.distance_to(player.global_position)
	var target

	if force_graph_path:
		var next_node = get_lookahead_target()
		if next_node != null:
			target = next_node
		else:
			# Path is empty — go direct, obstacle is no longer in the way
			target = player.global_position
			# Also clear force flag locally so we don't keep re-entering this state
			force_graph_path = false
	else:
		if dist_to_player < 20.0 and has_line_of_sight():
			target = player.global_position
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
	var current_speed = get_terrain_speed()
	velocity = velocity.lerp(dir * current_speed, 6.0 * delta)
	move_and_slide()

	# Remove passed nodes aggressively to avoid stalling
	while path.size() > 0 and global_position.distance_to(path[0]) < 1.0:
		path.pop_front()

	_animate_mesh(delta)
