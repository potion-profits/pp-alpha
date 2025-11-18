extends Node2D

@onready var tilemap : TileMapLayer = $Floor
@onready var counters : TileMapLayer = $Counters
@onready var floor_markers : Node2D = $FloorMarkers
var spawn : Vector2i
var shelves : Array = []
var checkout : Vector2i
var astar : Object

# create new astar grid
# get position of markers for points of interest in tilemap
func _ready() -> void:
	astar = AStarGrid2D.new()
	for child in floor_markers.get_children():
		var cell : Vector2i = tilemap.local_to_map(child.position)
		
		match child.name.split(" ")[0]:
			"Spawn":
				spawn = cell
			"Shelf":
				shelves.append(cell)
			"Checkout":
				checkout = cell
	print(spawn, " = Spawn cell\n",shelves, " = Shelf cells\n", checkout, " = Checkout cell")
	setup_grid()

# update astar properties from tilemap
func setup_grid() -> void:
	astar.size =  tilemap.get_used_rect().size
	astar.offset = tilemap.get_used_rect().position
	astar.cell_size = tilemap.tile_set.tile_size
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	
	astar.update()
	
	# set counter cells as not walkable
	# TO-DO: set cells that contain shelves as unwalkable
	for cell in counters.get_used_cells():
		var target : Vector2i = cell - Vector2i(astar.offset)
		astar.set_point_solid(target, true)
	
	print(counters.get_used_cells(), "\n", astar.get_id_path(shelves[-1] - Vector2i(astar.offset), checkout - Vector2i(astar.offset)))

func tile_to_id(tile_cell: Vector2i) -> Vector2i:
	return tile_cell - Vector2i(astar.offset)

func id_to_tile(id_cell: Vector2i) -> Vector2i:
	return id_cell + Vector2i(astar.offset)
