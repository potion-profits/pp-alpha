extends Node2D

@onready var tilemap : TileMapLayer = $Floor
@onready var counters : TileMapLayer = $Counters
@onready var entity_manager: EntityManager = $"../EntityManager"
@onready var spawn_marker: Marker2D = $Spawn
@onready var checkout_marker: Marker2D = $Checkout
var spawn : Vector2i
var shelf_cells : Array[Vector2i] = []
var shelf_targets : Array[Vector2i] = []
var checkout : Vector2i
var astar : Object

# create new astar grid
# get position of markers for points of interest in tilemap
func _ready() -> void:
	astar = AStarGrid2D.new()
	for child in entity_manager.get_children():
		if child.name.begins_with("shelf"):
			child._ready()
			var cell : Vector2i = tilemap.local_to_map(child.position)
			var cells : Array[Vector2i] = [cell, cell + Vector2i(1,0), cell + Vector2i(-1,0)]
			shelf_cells.append_array(cells)
			var y_offset : Vector2 = Vector2(0, 0.5 * child.collision.shape.get_rect().size.y)
			shelf_targets.append(tilemap.local_to_map(child.position + y_offset))
	spawn = tilemap.local_to_map(spawn_marker.position)
	checkout = tilemap.local_to_map(checkout_marker.position)
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
	for cell in counters.get_used_cells() + shelf_cells:
		var target : Vector2i = cell - Vector2i(astar.offset)
		astar.set_point_solid(target, true)

func tile_to_id(tile_cell: Vector2i) -> Vector2i:
	return tile_cell - Vector2i(astar.offset)

func id_to_tile(id_cell: Vector2i) -> Vector2i:
	return id_cell + Vector2i(astar.offset)
