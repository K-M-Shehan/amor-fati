extends Area3D

@export var sound: AudioStream
@export var play_once: bool = true
@export var auto_play_on_enter: bool = true

var triggered := false

@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name != "Player":
		return

	if play_once and triggered:
		return

	triggered = true

	if sound:
		audio.stream = sound
		audio.play()
