extends CharacterBody3D

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
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # mouse comes back when esc is pressed

func _physics_process(delta):
	const SPEED = 5.5
	
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
		
	move_and_slide()
