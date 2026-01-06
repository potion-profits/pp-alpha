extends Node2D

@onready var tilemap : TileMapLayer = $Floor
@onready var counters : TileMapLayer = $Counters
@onready var entity_manager: EntityManager = $"../../EntityManager"
@onready var spawn_marker: Marker2D = $Spawn
@onready var checkout_marker: Marker2D = $Checkout
var spawn : Vector2i
var shelf_tiles : Array[Vector2i] = []
var shelf_targets : Array[Vector2i] = []
var checkout : Vector2i
var astar : Object

# create new astar grid
# get position of markers for points of interest in tilemap
func _ready() -> void:
	prep_astar.call_deferred()
	
func prep_astar() -> void:
	astar = AStarGrid2D.new()
	for child in entity_manager.get_children():
		if child is Entity and child.entity_code == "shelf":
			# get tilemap tiles for shelves to make solid
			var cell : Vector2i = tilemap.local_to_map(child.global_position)
			shelf_tiles.append(cell)
			for shelf_child in child.get_children():
				if shelf_child.name == "NpcTarget":
					var target_tile : Vector2i = tilemap.local_to_map(shelf_child.global_position)
					shelf_targets.append(target_tile)
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
	for cell in counters.get_used_cells() + shelf_tiles:
		var target : Vector2i = cell - Vector2i(astar.offset)
		astar.set_point_solid(target, true)

func tile_to_id(tile_cell: Vector2i) -> Vector2i:
	"""Converts a tilemap tile to its respective atar grid id"""
	return tile_cell - Vector2i(astar.offset)

func id_to_tile(id_cell: Vector2i) -> Vector2i:
	"""Converts an astar grid id to its respective tilemap tile"""
	return id_cell + Vector2i(astar.offset)
