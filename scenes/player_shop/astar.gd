extends Node2D

## Contains all tilemap and astar grid data necessary for NPC pathing

## Main floor tilemap
@onready var tilemap : TileMapLayer = $Floor
## Tilemap for the counters
@onready var counters : TileMapLayer = $Counters
## Reference to scene's [EntityManager] to get all shelf children
@onready var entity_manager: EntityManager = $"../../EntityManager"
## Marks spawn coordinates
@onready var spawn_marker: Marker2D = $Spawn
## Marks checkout coordinates
@onready var checkout_marker: Marker2D = $Checkout
## Reference to tilemap for walls, used to exclude all wall tiles from astar grid
@onready var walls: TileMapLayer = $"../Walls"
## Tile on floor for spawn
var spawn : Vector2i
## Tiles on floor for shelf
var shelf_tiles : Array[Vector2i] = []
## Tiles on floor for NPCs to target and move to shelves
var shelf_targets : Array[Vector2i] = []
## Tile on floor for checkout
var checkout : Vector2i
## [AStarGrid2D] for NPC pathing
var astar : Object

# create new astar grid
# get position of markers for points of interest in tilemap
func _ready() -> void:
	prep_astar.call_deferred()

## Creates the astar object and assigns all significant tiles for pathing
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
					if target_tile in tilemap.get_used_cells():
						shelf_targets.append(target_tile)
	spawn = tilemap.local_to_map(spawn_marker.position)
	checkout = tilemap.local_to_map(checkout_marker.position)
	setup_grid()

## See [AStarGrid2D] for [method AStarGrid2D.update]. Sets all counter and shelf tiles to solid 
## (unwalkable)
func setup_grid() -> void:
	astar.size =  tilemap.get_used_rect().size
	astar.offset = tilemap.get_used_rect().position
	astar.cell_size = tilemap.tile_set.tile_size
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	
	astar.update()
	
	# set counter cells as not walkable
	# TO-DO: set cells that contain shelves as unwalkable
	for cell in counters.get_used_cells() + walls.get_used_cells() + shelf_tiles:
		var target : Vector2i = tile_to_id(cell)
		if cell == spawn or not astar.is_in_bounds(target.x, target.y):
			continue
		astar.set_point_solid(target, true)

## Translates a tilemap tile to an AstarGrid id
func tile_to_id(tile_cell: Vector2i) -> Vector2i:
	return tile_cell - Vector2i(astar.offset)

## Translates an AstarGrid id to a tilemap tile
func id_to_tile(id_cell: Vector2i) -> Vector2i:
	return id_cell + Vector2i(astar.offset)

func _debug_astar_grid() -> void:
	for i in range(astar.region.position.x, astar.region.end.x):
		for j in range(astar.region.position.y, astar.region.end.y):
			var id : Vector2i = Vector2i(i,j)
			var new_tile : Vector2i = Vector2i(15,11) # points to door tile in floor tileset
			if not astar.is_point_solid(id):
				var tile : Vector2i = id_to_tile(id)
				tilemap.set_cell(tile, 0,new_tile)
