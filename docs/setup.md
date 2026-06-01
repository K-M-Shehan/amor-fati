# Setup & Quick Start (Godot 4)

Prereqs
- Godot 4.x installed (editor + export templates as needed).

Open project
1. Launch Godot, choose "Open" and select the project folder (contains `project.godot`).
2. Open the main menu scene: `scenes/levels/main_menu.tscn`.

Run
- Press Play in the editor to run the current scene. To run the game from the main menu, open `scenes/levels/main_menu.tscn` and press Play.

Input map (recommended bindings)
- `move_left`, `move_right`, `move_forward`, `move_back`: WASD or arrow keys
- `jump`: Space
- `interact`: E
- `ui_cancel`: Esc
- `barricade`: B (level-specific)
- `throw_holy_water`: F (level-specific)

Save & settings
- `SaveManager` persists to `user://progress.cfg`.

Notes
- Many assets have `.import` sidecars — reimport via the editor if you replace source files.
