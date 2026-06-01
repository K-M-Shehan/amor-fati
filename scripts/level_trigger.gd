extends Area3D

@export var next_level: String = ""
@export var this_level_number: int = 1   # set this in Inspector per level trigger

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		# Unlock the next level before transitioning
		SaveManager.unlock_level(this_level_number + 1)
		_fade_and_change()

func _fade_and_change() -> void:
	var music = get_tree().current_scene.get_node_or_null("MusicPlayer")
	if music != null:
		var tween = create_tween()
		tween.tween_property(music, "volume_db", -40.0, 0.8)
		await tween.finished
	get_tree().change_scene_to_file.call_deferred(next_level)
