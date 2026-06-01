extends CharacterBody3D

var level_graph: Graph = null
var is_dead = false

# bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

@export var footstep_sound: AudioStream = null

@onready var _footstep_player = $FootstepPlayer
var _footstep_timer: float = 0.0
var _footstep_interval: float = 0.50   # seconds between steps — tune to match animation

@onready var head = $Head
@onready var camera = %Camera3D
@onready var ray = $Head/Camera3D/InteractRay
@onready var ui_label = $"CanvasLayer/InteractionLabel"
@onready var key_ui = $"CanvasLayer/KeyCounter"

func update_ui():
	key_ui.text = "Keys: %d" % [keys_collected]

var keys_collected = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # removes pointer from game

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# rotate around y axis
		# for sensitivity when rotating, we multiply or divide the below assigned value
		rotation_degrees.y -= event.relative.x * 0.5 # can also be / 2.0 instead of * 0.5
		
		# rotate around x axis (we will be rotating the camera here not the whole character like we did earlier)
		%Camera3D.rotation_degrees.x -= event.relative.y / 5.0 # same as multiplying by 0.2
		
		# limit camera rotation in the x axis 
		%Camera3D.rotation_degrees.x = clamp(
			%Camera3D.rotation_degrees.x, -80.0, 80.0
		)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			# Only recapture if game is not paused
			if not get_tree().paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var SPEED = get_terrain_speed()
	
	var input_direction_2D = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	
	var input_direction_3D = Vector3(
		input_direction_2D.x, 0.0, input_direction_2D.y
	)
	
	var direction = transform.basis * input_direction_3D
	
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	if not is_on_floor():
		velocity.y -= 20 * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 7
	
	# head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob) # don't change this to head, your device will spontaneously combust
		
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		var body = col.get_collider()

		if body is RigidBody3D:
			var force = -col.get_normal()
			force.y = 0
			force = force.normalized()

			body.apply_impulse(force * 2.5)
	
	_handle_footsteps(delta)
	handle_interaction()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func get_terrain_speed() -> float:
	if level_graph == null:
		return 5.5
	for id in level_graph.nodes:
		var node = level_graph.nodes[id]
		if global_position.distance_to(node.position) < 8.0:
			match node.terrain_type:
				Waypoint.TileType.MUD:
					return 2.0
				Waypoint.TileType.WATER:
					return 3.5
	return 5.5
	
func collect_key():
	keys_collected += 1
	update_ui()
	
func handle_interaction():

	if ray.is_colliding():

		var collider = ray.get_collider()
		
		# godot helper
		if not is_instance_valid(collider):
			return

		# FIX: check null
		if collider == null:
			ui_label.visible = false
			return

		# fix: handle mesh hits
		if not collider.has_method("interact") and collider.get_parent():
			collider = collider.get_parent()

		# FIX again after reassignment
		if collider == null:
			ui_label.visible = false
			return

		if collider.has_method("interact"):

			var dist = global_position.distance_to(collider.global_position)

			if dist < 2.5:
				ui_label.text = collider.get_interaction_text()
				ui_label.visible = true

				if Input.is_action_just_pressed("interact"):
					collider.interact(self)
					ui_label.visible = false
					return

				return

	ui_label.visible = false

func _get_footstep_interval() -> float:
	var spd = get_terrain_speed()
	if spd < 3.0:
		return 1.00   # mud — slow heavy steps
	elif spd < 4.5:
		return 0.80   # water — slightly slower
	return 0.50       # normal

func _handle_footsteps(delta: float) -> void:
	# Only play when moving on the ground
	var is_moving = Vector2(velocity.x, velocity.z).length() > 0.5
	if not is_moving or not is_on_floor():
		_footstep_timer = 0.0
		return

	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		_footstep_timer = _get_footstep_interval()

		# Slightly randomise pitch so steps don't sound identical
		_footstep_player.pitch_scale = randf_range(0.92, 1.08)

		if footstep_sound != null:
			_footstep_player.stream = footstep_sound
			_footstep_player.play()

func _reload_scene():
	get_tree().reload_current_scene()
		
func die():
	if is_dead:
		return
	is_dead = true

	print("Player died!")
	call_deferred("_reload_scene")
