# `player.gd` — Player controller

Location: `scripts/player.gd`

Summary
- `CharacterBody3D` controller handling movement, head-bob, camera look, interaction ray, footsteps, and key collection.

Important exported / onready
- `footstep_sound` (AudioStream)
- `head`, `camera`, `ray` references

Key methods
- `_ready()`: capture mouse
- `_unhandled_input(event)`: mouse look handling using `SaveManager.mouse_sensitivity`
- `_physics_process(delta)`: movement, gravity, jumping, head-bob, slide collision impulses
- `get_terrain_speed()`: returns speed based on nearest waypoint `terrain_type`
- `handle_interaction()`: uses `Head/Camera3D/InteractRay` to call `interact()` on colliders
- `_handle_footsteps(delta)`: plays footstep AudioStreamPlayer3D with pitch variance
- `die()`: defers scene reload

Notes
- Interaction checks parent fallback for mesh hits.
- Footstep cadence adjusts to terrain via `_get_footstep_interval()`.

## Code excerpts

Movement & input handling
```gdscript
var input_direction_2D = Input.get_vector(
	"move_left", "move_right", "move_forward", "move_back"
)
var input_direction_3D = Vector3(input_direction_2D.x, 0.0, input_direction_2D.y)
var direction = transform.basis * input_direction_3D
velocity.x = direction.x * SPEED
velocity.z = direction.z * SPEED
```

Interaction ray (simplified)
```gdscript
if ray.is_colliding():
	var collider = ray.get_collider()
	if not collider.has_method("interact") and collider.get_parent():
		collider = collider.get_parent()
	if collider.has_method("interact") and global_position.distance_to(collider.global_position) < 2.5:
		collider.interact(self)
```

Footsteps playback
```gdscript
_footstep_timer -= delta
if _footstep_timer <= 0.0:
	_footstep_timer = _get_footstep_interval()
	_footstep_player.pitch_scale = randf_range(0.92, 1.08)
	if footstep_sound != null:
		_footstep_player.stream = footstep_sound
		_footstep_player.play()
```
