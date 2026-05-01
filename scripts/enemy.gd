extends CharacterBody3D

var path = []
var speed = 3.0
var player

func _ready():
	player = get_parent().get_node("Player")
	$KillZone.body_entered.connect(_on_body_entered)

func set_path(p: Array, graph: Graph):
	# only update if new path is different
	if p.size() == 0:
		return

	path.clear()

	for id in p:
		path.append(graph.nodes[id].position)
		
func _on_body_entered(body):
	if body.name == "Player":
		print("Player killed (enemy caught)")
		body.die()

func _physics_process(_delta):

	var target

	# if close enough to player → chase directly
	if global_position.distance_to(player.global_position) < 15.0:
		target = player.global_position

	# otherwise follow graph
	elif path.size() > 0:
		target = path[0]

	else:
		target = player.global_position

	var dir = (target - global_position).normalized()

	velocity = dir * speed
	move_and_slide()

	# move along path
	if path.size() > 0 and global_position.distance_to(path[0]) < 0.3:
		path.pop_front()
