extends Control

@onready var sensitivity_slider = $CanvasLayer/VBoxContainer/HBoxContainer/SensitivitySlider
@onready var sensitivity_value  = $CanvasLayer/VBoxContainer/HBoxContainer/SensitivityValue
@onready var volume_slider      = $CanvasLayer/VBoxContainer/HBoxContainer2/VolumeSlider
@onready var volume_value       = $CanvasLayer/VBoxContainer/HBoxContainer2/VolumeValue

func _ready() -> void:
	# Sensitivity slider
	sensitivity_slider.min_value = 0.1
	sensitivity_slider.max_value = 1.0
	sensitivity_slider.step      = 0.05
	sensitivity_slider.value     = SaveManager.mouse_sensitivity
	_update_sensitivity_label(SaveManager.mouse_sensitivity)

	# Volume slider
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step      = 0.05
	volume_slider.value     = SaveManager.master_volume
	_update_volume_label(SaveManager.master_volume)

	# Connect sliders
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	volume_slider.value_changed.connect(_on_volume_changed)

func _on_sensitivity_changed(value: float) -> void:
	SaveManager.mouse_sensitivity = value
	SaveManager.save_progress()
	_update_sensitivity_label(value)

func _on_volume_changed(value: float) -> void:
	SaveManager.master_volume = value
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(value)
	)
	SaveManager.save_progress()
	_update_volume_label(value)

func _update_sensitivity_label(value: float) -> void:
	if sensitivity_value != null:
		sensitivity_value.text = "%d%%" % int(value * 100)

func _update_volume_label(value: float) -> void:
	if volume_value != null:
		volume_value.text = "%d%%" % int(value * 100)

func _on_reset_progress_button_pressed() -> void:
	SaveManager.reset_progress()
	var btn = $CanvasLayer/VBoxContainer/ResetProgressButton
	btn.text = "Progress Reset!"
	await get_tree().create_timer(1.5).timeout
	btn.text = "Reset Progress"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
