# `sound_trigger.gd` — Area-based audio triggers

Location: `scripts/sound_trigger.gd`

Summary
- Plays a configured `AudioStream` via an in-scene `AudioStreamPlayer3D` when the `Player` enters the area. Supports `play_once` to avoid repeating.

Exports
- `sound` (AudioStream), `play_once` (bool), `auto_play_on_enter` (bool).

Behavior
- Connects `body_entered` on `_ready()`, checks `body.name == "Player"`, and plays `audio.stream` on the `AudioStreamPlayer3D` child.

Code excerpt
```gdscript
func _on_body_entered(body):
    if body.name != "Player":
        return
    if play_once and triggered:
        return
    triggered = true
    if sound:
        audio.stream = sound
        audio.play()
```
