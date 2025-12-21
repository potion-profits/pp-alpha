extends GutTest

var shop_scene : Resource = load("res://scenes/player_shop/main_shop.tscn")
var shop : Node = null
var npc_scene : Resource = load("res://scenes/npc_alt/basic_npc.tscn")
var npc : Node = null

func before_each() -> void:
	shop = shop_scene.instantiate()
	add_child_autofree(shop)
	await wait_process_frames(2)
	
	npc = npc_scene.instantiate()
	add_child_autofree(npc)
	shop.setup_npc(npc)
	await wait_process_frames(1)

func after_each() -> void:
	pass

func test_npc_has_preferred_item() -> void:
	assert_not_null(npc.preferred_item)

func test_npc_path_to_shelf() -> void:
	assert_not_null(npc.target, "NPC should have a target to move towards")
	assert_has(shop.floor_map.shelf_targets, npc.target, "NPC should be moving to a shelf")
	assert_eq(npc.current_action, npc.action.GET_POTION, "NPC should be searching for a potion")
	while !npc.current_path.is_empty():
		await wait_process_frames(1)
	assert_eq(npc.floor_map.tilemap.local_to_map(npc.global_position), npc.target,
		"NPC should be on same tile as target once path is complete")
