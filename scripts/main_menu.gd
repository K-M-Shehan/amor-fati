extends Control

@onready var letters = [
	$CanvasLayer/Letter1,
	$CanvasLayer/Letter2,
	$CanvasLayer/Letter3,
	$CanvasLayer/Letter4,
	$CanvasLayer/Letter5,
	$CanvasLayer/Letter6,
	$CanvasLayer/Letter7,
	$CanvasLayer/Letter8,
]

func _ready():
	for letter in letters:
		letter.modulate.a = 0.0
	await get_tree().create_timer(0.3).timeout
	reveal_title()

func reveal_title():
	for letter in letters:
		var original_pos = letter.position
		letter.position.y -= 20.0
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(letter, "modulate:a", 1.0, 0.2)
		tween.tween_property(letter, "position:y", original_pos.y, 0.2)
		await tween.finished

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")
	
func _on_options_button_pressed() -> void:
	pass # Replace with function body.

func _on_credits_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	get_tree().quit()
