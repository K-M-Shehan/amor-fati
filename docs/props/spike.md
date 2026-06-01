# `spike.gd` — Hazard

Location: `scripts/props/spike.gd`

Summary
- Simple `Area3D` that kills the player on contact by calling `body.die()`.

Code excerpt
```gdscript
func _on_body_entered(body):
    if body.name == "Player":
        body.die()
```
