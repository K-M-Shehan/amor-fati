class_name PathNode

var id: int
var position: Vector3

var neighbors = []

var terrain_cost: float = 1.0
var blocked: bool = false
var terrain_type:int = Waypoint.TileType.NORMAL
