extends GutTest

var shop_scene : Resource = load("res://scenes/player_shop/main_shop.tscn")
var shop : Node = null
var npc_scene : Resource = load("res://scenes/npc_alt/basic_npc.tscn")
var npc : Node = null

func before_each() -> void:
	shop = shop_scene.instantiate()
	var spawner : Node2D = shop.get_node("NpcSpawner")
	add_child_autofree(shop)
	await wait_process_frames(2)
	spawner.npc_respawn_timer.stop()
	
	npc = npc_scene.instantiate()
	add_child_autofree(npc)
	shop.setup_npc(npc)
	await wait_process_frames(2)

func after_each() -> void:
	pass

func test_npc_has_preferred_item() -> void:
	assert_not_null(npc.preferred_item)

func test_npc_path_to_shelf() -> void:
	assert_not_null(npc.target, "NPC should have a target to move towards")
	assert_has(shop.floor_map.shelf_targets, npc.target, "NPC should be moving to a shelf")
	assert_eq(npc.current_action, npc.action.GET_POTION, "NPC should be searching for a potion")
	assert_eq(npc.current_path[-1], npc.target, "NPC path should end at target shelf")

func test_npc_path_to_checkout() -> void:
	npc.item_found = true
	npc.npc_action()
	assert_eq(npc.current_action, npc.action.CHECKOUT, "NPC should be in checkout state")
	assert_eq(npc.checkout, npc.target, "NPC should be targeting checkout when item is found")
	assert_eq(npc.current_path[-1], npc.checkout, "NPC path should end at checkout tile")

func test_npc_checks_all_shelves() -> void:
	var spawn : Vector2i = npc.floor_map.tilemap.local_to_map(npc.global_position)
	# manually reset shelves array
	npc.shelves = shop.floor_map.shelf_targets.filter(
		func(vec : Vector2i) -> bool: return vec != npc.target
		)
	while len(npc.shelves) > 0:
		assert_eq(npc.current_action, npc.action.GET_POTION, "NPC should be searching for potions")
		npc.npc_action()
	assert_eq(npc.shelves, [], "NPC should have popped all shelf locations")
	npc.npc_action()
	assert_eq(npc.current_action, npc.action.LEAVE, "NPC should be in leave state")
	assert_eq(npc.current_path[-1], spawn, "NPC path should end at spawn tile")

func test_npc_check_shelf() -> void:
	var shelf_scene : Resource = load("res://scenes/shelf/shelf.tscn")
	var shelf : Node = shelf_scene.instantiate()
	add_child_autofree(shelf)
	await wait_process_frames(1)
	var red:InvItem = ItemRegistry.new_item("item_red_potion")
	red.sellable = true
	npc.preferred_item = "item_red_potion"
	npc.check_shelf(shelf)
	assert_false(npc.item_found, "NPC should not have found their preferred item")
	shelf.inv.insert(red)
	npc.check_shelf(shelf)
	assert_true(npc.item_found, "NPC should have found their preferred item")
