# `ceiling_light.gd` — Ceiling light prop

Location: `scripts/props/ceiling_light.gd`

Summary
- Controls a `SpotLight3D` attached to the ceiling. Exposes `update_light(player_pos)` used by `light_manager.gd`.

Code excerpt
```gdscript
func update_light(player_pos: Vector3):
    var dist = global_position.distance_to(player_pos)
    if dist < 6.0:
        spot.visible = true
        spot.shadow_enabled = true
    elif dist < 12.0:
        spot.visible = true
        spot.shadow_enabled = false
    else:
        spot.visible = false
```
