extends GutTest

var Player_Scene : Resource = load("res://scenes/player/player.gd")
var bottle:InvItem = ItemRegistry.new_item("item_empty_bottle");
var red:InvItem = ItemRegistry.new_item("item_red_potion");
var green:InvItem = ItemRegistry.new_item("item_green_potion")
var blue:InvItem = ItemRegistry.new_item("item_blue_potion")
var black:InvItem = ItemRegistry.new_item("item_dark_potion")
var player : Node = null

func before_each() -> void:
	player = Player_Scene.new()
	player.set_physics_process(false)
	add_child_autoqfree(player)	#auto queue free objects on after_each call

# required to queue_free objects added to scene tree
func after_each() -> void:
	pass

func test_set_coins_lt_zero() -> void:
	player.coins = 10
	player.set_coins(-15)
	assert_eq(player.coins, 10, "Player coins should return same number on invalid transaction")

func test_set_coins_gt_max() -> void:
	var init : int = int(player.MAX_COINS) - 2
	player.coins = init
	player.set_coins(5)
	assert_eq(player.coins, init, "Player coins should return same number on invalid transaction")

func test_set_chips_lt_zero() -> void:
	player.chips = 10
	player.set_chips(-15)
	assert_eq(player.chips, 10, "Player chips should return same number on invalid transaction")

func test_set_chips_gt_max() -> void:
	var init : int = int(player.MAX_COINS) - 2
	player.chips = init
	player.set_chips(5)
	assert_eq(player.chips, init, "Player chips should return same number on invalid transaction")

func test_set_and_get_coins() -> void:
	player.coins = 10
	player.set_coins(5)
	assert_eq(player.get_coins(), 15, "Set coins to 10 and added 5, should get 15 coins")

func test_set_and_get_chips() -> void:
	player.chips = 10
	player.set_chips(5)
	assert_eq(player.get_chips(), 15, "Set chips to 10 and added 5, should get 15 chips")

# should be moved to unit testing on inventories
func test_new_inv_is_empty() -> void:
	player.inv = Inv.new()
	for slot : InvSlot in player.inv.slots:
		assert_null(slot.item, "Inv slots should be null on new player inventory")

func test_has_empty_slots() -> void:
	player.inv = Inv.new()
	player.inv.insert(bottle)
	player.inv.insert(red)
	player.inv.insert(blue)
	player.inv.insert(green)
	assert_true(player.has_empty_slot(), "Player inv should have 4 full slots and 1 empty")
	player.inv.insert(black)
	assert_false(player.has_empty_slot(), "Player inv should have 5 full slots")

func test_can_stack_items() -> void:
	player.inv = Inv.new()
	assert_false(player.can_stack_item(red), "Player doesn't have any red, can't stack red")
	player.inv.insert(red)
	assert_true(player.can_stack_item(red), "Player has red, can stack red")
