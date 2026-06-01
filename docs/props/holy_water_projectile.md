# `holy_water_projectile.gd` — Throwable projectile

Location: `scripts/props/holy_water_projectile.gd`

Summary
- Simple kinematic projectile that simulates gravity, detects ground contact, and calls `level.trigger_barricade(pos)` when it lands.

Code excerpt
```gdscript
func launch(direction: Vector3, force: float = 10.0) -> void:
    velocity = direction * force + Vector3.UP * 4.0

func _physics_process(delta: float) -> void:
    velocity.y -= gravity * delta
    global_position += velocity * delta
    var query = PhysicsRayQueryParameters3D.create(global_position, global_position + Vector3.DOWN * 0.3)
    var result = space.intersect_ray(query)
    if result:
        _land(result.position)
```
