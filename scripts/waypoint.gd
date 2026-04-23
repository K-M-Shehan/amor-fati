extends Node3D
class_name Waypoint

@export var id: int

enum TileType {
	NORMAL,
	MUD,
	WATER,
	SPIKE
}

@export var tile_type: TileType = TileType.NORMAL
