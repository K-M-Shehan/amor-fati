# Assets & import notes

- Many assets include `.import` sidecar files (Godot's importer metadata). If you swap source files, delete the related `.import` file and re-import in the Godot editor.
- Meshes: ensure consistent normals/tangents when exporting from modelling tools.
- Textures: tune compression and sRGB/linear settings in the import dock for best results.

Folders of interest
- `assets/` — raw asset sources and imported meta
- `textures/` — game textures
