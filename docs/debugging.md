# Debugging & Testing Tips

- Enable pathfinding visualizer: set `BaseLevel.enable_debug_visualizer = true` in the inspector.
- Use the Remote Scene Tree (Run → Remote Scene Tree) to inspect runtime node state and exported properties.
- Search for `print()` statements to find existing debug output (enemy activation, player death, graph printouts).
- To reproduce path issues: enable visualizer, log `builder.graph` contents, and test with crates/puddles to force graph mode.
