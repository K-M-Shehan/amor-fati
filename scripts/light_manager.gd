extends Node3D

@export var player: Node3D

var lights = []

func _ready():
	lights = get_tree().get_nodes_in_group("ceiling_lights")

func _process(_delta):
	var player_pos = player.global_position

	for light in lights:
		light.update_light(player_pos)
