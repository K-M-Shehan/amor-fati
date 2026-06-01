# `light_manager.gd` — Ceiling light manager

Location: `scripts/light_manager.gd`

Summary
- Manages grouped ceiling lights and updates their visibility/shadow state based on player distance.

Behavior
- Collects nodes in group `ceiling_lights` on `_ready()` and stores them in `lights`.
- Every frame, it computes each light's `update_light(player_pos)` to enable/disable the `SpotLight3D` and shadows depending on distance thresholds.

Code excerpt
```gdscript
func _process(_delta):
    var player_pos = player.global_position
    for light in lights:
        light.update_light(player_pos)
```

Notes
- Each ceiling light uses `scripts/props/ceiling_light.gd` which exposes `update_light(player_pos)` that toggles `spot.visible` and `spot.shadow_enabled` based on distance buckets (e.g., <6, <12, else off).
