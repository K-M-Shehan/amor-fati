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
@onready var buttons = [
	$CanvasLayer/VBoxContainer/StartButton,
	$CanvasLayer/VBoxContainer/CreditsButton,
	$CanvasLayer/VBoxContainer/OptionsButton,
	$CanvasLayer/VBoxContainer/ExitButton,
]
@onready var continue_button = $CanvasLayer/VBoxContainer/ContinueButton

func _ready():
	for letter in letters:
		letter.modulate.a = 0.0

	# Hide all buttons including continue at start
	for button in buttons:
		button.modulate.a = 0.0
	continue_button.modulate.a = 0.0
	continue_button.visible = false   # hidden until we know progress

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
	await get_tree().create_timer(0.3).timeout
	reveal_buttons()

func reveal_buttons():
	# If continue is available, show it first before other buttons
	if SaveManager.furthest_level > 1:
		continue_button.visible = true
		var tween = create_tween()
		tween.tween_property(continue_button, "modulate:a", 1.0, 0.2)
		await tween.finished

	# Then fade in the rest
	for button in buttons:
		var tween = create_tween()
		tween.tween_property(button, "modulate:a", 1.0, 0.2)
		await tween.finished

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_continue_button_pressed() -> void:
	var level_path = "res://scenes/levels/level%d.tscn" % SaveManager.furthest_level
	get_tree().change_scene_to_file(level_path)

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/credits.tscn")

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/options_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
