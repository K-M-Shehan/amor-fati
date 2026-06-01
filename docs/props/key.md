# `key.gd` — Pickup prop

Location: `scripts/props/key.gd`

Summary
- Area-based key pickup. Calls `player.collect_key()` and plays pickup sound. Delays `queue_free()` so sound can play.

Code excerpt
```gdscript
func interact(player):
    player.collect_key()
    if pickup_sound:
        _sound.stream = pickup_sound
        _sound.play()
    await get_tree().create_timer(0.3).timeout
    queue_free()
```
