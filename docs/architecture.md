# Architecture

High-level systems
- Graph & waypoints: scripts/graph.gd, scripts/graph_builder.gd → builds waypoint graph from nodes in group waypoints.
- Pathfinding: scripts/astar.gd (A*), scripts/bfs.gd (BFS).
- Level orchestration: scripts/base_level.gd and per-level scripts under scripts/level*.gd.
- Actors: scenes/actors/player.tscn + scripts/player.gd; scenes/actors/enemy.tscn + scripts/enemy.gd.
- Systems: scripts/save_manager.gd, scripts/light_manager.gd, audio triggers in scripts/sound_trigger.gd.

Mermaid diagram

mermaid
flowchart TD
  subgraph Scenes
    MainMenu["scenes/levels/main_menu.tscn"]
    LevelScene["scenes/levels/levelN.tscn"]
    PlayerScene["scenes/actors/player.tscn"]
    EnemyScene["scenes/actors/enemy.tscn"]
  end

  subgraph Systems
    GraphBuilder["scripts/graph_builder.gd"]
    Graph["scripts/graph.gd"]
    AStar["scripts/astar.gd"]
    BFS["scripts/bfs.gd"]
    BaseLevel["scripts/base_level.gd"]
    SaveManager["scripts/save_manager.gd (singleton)"]
  end

  MainMenu -->|change_scene| LevelScene
  LevelScene -->|contains| PlayerScene
  LevelScene -->|contains| EnemyScene
  LevelScene --> BaseLevel
  BaseLevel --> GraphBuilder --> Graph
  Graph --> AStar
  Graph --> BFS
  PlayerScene -->|reads| Graph
  EnemyScene -->|reads/writes| Graph
  All -->|reads/writes| SaveManager