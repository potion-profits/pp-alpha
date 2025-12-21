extends GutTest

var shop_scene : Resource = load("res://scenes/player_shop/main_shop.tscn")
var shop : Node = null

func before_each() -> void:
	shop = shop_scene.instantiate()
	add_child_autofree(shop)
	await wait_process_frames(2)		# lets scene ready

func after_each() -> void:
	pass

func test_astar_is_initialized() -> void:
	assert_not_null(shop.floor_map, "Astar tilemap should have initialized")
	assert_not_null(shop.floor_map.astar, "Astar grid should have initialized")
