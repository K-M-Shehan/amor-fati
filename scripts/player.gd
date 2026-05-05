extends CharacterBody3D

var has_key = false
var is_dead = false
@onready var ray = $Camera3D/InteractRay
@onready var ui_label = $"CanvasLayer/InteractionLabel"
@onready var key_ui = $"CanvasLayer/KeyCounter"

func update_ui():
	key_ui.text = "Keys: %d/%d" % [keys_collected, total_keys]

var keys_collected = 0
var total_keys = 2

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
	
	handle_interaction()
	
func collect_key():
	keys_collected += 1
	has_key = keys_collected >= total_keys

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


func _reload_scene():
	get_tree().reload_current_scene()
		
func die():
	if is_dead:
		return
	is_dead = true

	print("Player died!")
	call_deferred("_reload_scene")
