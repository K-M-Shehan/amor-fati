# `door.gd` — Door prop

Location: `scripts/props/door.gd`

Summary
- Area-based door that requires `keys_needed` to open. Uses tweens to animate hinge rotation and plays open/close sounds.

Code excerpt
```gdscript
func interact(player):
    if player.keys_collected >= keys_needed and is_open == false:
        open_door()
        is_open = true

func open_door():
    var tween = create_tween()
    tween.tween_property($Door/Hinge, "rotation_degrees:y", -90, 1.0)
    _play_sound(sound_open)
```
