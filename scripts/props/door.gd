extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_key:
			print("Door opened! Level complete!")
			get_tree().reload_current_scene() # TEMP (we'll change later)
		else:
			print("Door is locked!")
