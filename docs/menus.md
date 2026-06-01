# Menus & UI Scenes

This covers the game's menus and UI flow: main menu, options, pause menu, credits, and end card.

Main menu (`scripts/main_menu.gd`)
- Animates letters and fades in buttons.
- `ContinueButton` is shown if `SaveManager.furthest_level > 1`.
- Scene changes: `Start` → `scenes/levels/level1.tscn`, `Continue` → level path by `SaveManager.furthest_level`.

Options menu (`scripts/options_menu.gd`)
- Binds sliders to `SaveManager.mouse_sensitivity` and `SaveManager.master_volume`.
- Updates `AudioServer` immediately on volume change and saves settings.

Pause menu (`scripts/pause_menu.gd`)
- Implemented as a `CanvasLayer` that `show()`/`hide()` and toggles `get_tree().paused`.
- Ensures `process_mode = Node.PROCESS_MODE_ALWAYS` so UI remains responsive while paused.

Credits & End card (`scripts/credits.gd`, `scripts/end_card.gd`)
- Similar reveal animation patterns for title letters and fade-in buttons.
- Buttons either return to main menu, advance to credits, or quit.

Code excerpts
```gdscript
# options_menu: bind slider
sensitivity_slider.value = SaveManager.mouse_sensitivity
sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

# pause_menu: open/close
func open() -> void:
    show()
    get_tree().paused = true
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close() -> void:
    hide()
    get_tree().paused = false
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
```
