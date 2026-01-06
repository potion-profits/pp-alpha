extends GutTest

var shop_scene : Resource = load("res://scenes/player_shop/main_shop.tscn")
var shop : Node = null

func before_each() -> void:
	shop = shop_scene.instantiate()
	add_child_autofree(shop)
	await wait_process_frames(2)		# lets scene ready

func after_each() -> void:
	pass

func test_astar_initialized() -> void:
	var astar : Node = shop.floor_map
	assert_not_null(astar.spawn, "Astar/tilemap should have spawn coordinates, but spawn set to null")
	# may fail when we switch to placeable shop entities
	assert_not_null(astar.shelf_tiles, "Astar/tilemap should have shelf coordinates, but shelf cells empty")
	assert_not_null(astar.checkout, "Astar/tilemap should have checkout coordinates, but checkout set to null")
	
func test_setup_npc() -> void:
	var npc_scene : Resource = load("res://scenes/npc_alt/basic_npc.tscn")
	var npc_instance : Node2D = npc_scene.instantiate()
	add_child_autofree(npc_instance)
	shop.setup_npc(npc_instance)
	assert_eq(npc_instance.floor_map, shop.floor_map, "NPC should recieve tilemap/astar grid from shop")
	# replace popped target to test npc shelves and floor_map shelf_targets equality
	npc_instance.shelves.append(npc_instance.target)
	npc_instance.shelves.sort()
	shop.floor_map.shelf_targets.sort()
	assert_eq(npc_instance.shelves, shop.floor_map.shelf_targets, "NPC should receieve shelf coords from shop")
	assert_not_null(npc_instance.target, "NPC should have a target to move to")
	assert_has(shop.floor_map.shelf_targets, npc_instance.target, "NPC should target a shelf first")
	assert_eq(npc_instance.checkout, shop.floor_map.checkout, "NPC should recieve checkout coords from shop")
	var spawn_tilemap_tile : Vector2i = shop.floor_map.tilemap.local_to_map(shop.floor_map.spawn_marker.position)
	var npc_spawn_tile : Vector2i = npc_instance.floor_map.tilemap.local_to_map(npc_instance.global_position)
	assert_eq(spawn_tilemap_tile, npc_spawn_tile, "NPC should spawn on spawn marker tile")
	
