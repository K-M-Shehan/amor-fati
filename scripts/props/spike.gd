extends Area3D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Player hit spikes!")

		get_tree().reload_current_scene()
