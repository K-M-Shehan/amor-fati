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

func _physics_process(_delta):

	var target

	# if close enough to player → chase directly
	# if global_position.distance_to(player.global_position) < 2.0:
	#	target = player.global_position

	# otherwise follow graph
	if path.size() > 0:
		target = path[0]

	else:
		target = player.global_position

	var dir = (target - global_position).normalized()
	
	# rotation
	if dir.length() > 0.01:
		var target_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * _delta)

	velocity = dir * speed
	move_and_slide()

	# move along path
	if path.size() > 0 and global_position.distance_to(path[0]) < 0.3:
		path.pop_front()
