extends Node3D

@onready var spot = $SpotLight3D

func _ready():
	add_to_group("ceiling_lights")

func update_light(player_pos: Vector3):
	var dist = global_position.distance_to(player_pos)

	if dist < 6.0:
		spot.visible = true
		spot.shadow_enabled = true

	elif dist < 12.0:
		spot.visible = true
		spot.shadow_enabled = false

	else:
		spot.visible = false
