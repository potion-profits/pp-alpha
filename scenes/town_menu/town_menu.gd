extends Control

## Handles scene transitions to different locations and refills.
##
## Simulates a town where the player can enter a shop that refills shop supplies,
## the casino, or go to the player shop. 
##
## @experimental: Handles a simluated town but will be replaced with an actual town scene.

## Reference to container of buttons for each barrel color
@onready var barrels : VBoxContainer = $TabContainer/Barrels

## Mapping of abbreviation to barrel type code
var barrel_type_mapping : Dictionary = {
	"R": "red_barrel",
	"B": "blue_barrel",
	"G": "green_barrel",
	"D": "dark_barrel"
}

## Mapping of abbreviation to barrel price
var barrel_prices : Dictionary = {
	"R" : 50,
	"G" : 75,
	"B" : 100,
	"D" : 500
}

# crate prices
const CRATE_PRICE = 100

# Connects each button pressed signal to the barrel refill function
func _ready() -> void:
	for button : Button in barrels.get_children():
		button.pressed.connect(_on_barrels_refill_pressed.bind(button.name))
		pass

# Opens barrel refill scene with the given button name dictating the color
func _on_barrels_refill_pressed(button_name: String) -> void:
	var button_key: String = button_name[0]	# gets the button corresponding to the barrel type
	var coins: int = GameManager.player_data["coins"]
	var price: int = barrel_prices[button_key]
	if price <= coins:	# if player can purchase 
		# set up a payload with barrel, the cost of that color, and the type
		var payload : Dictionary = {
			"target" = "barrel",
			"cost" = price,
			"type" = barrel_type_mapping[button_key]
		}
		# change scene to refill selection
		SceneManager.change_to("res://scenes/refill_scene/backroom.tscn", payload)

# Opens crate refill scene 
func _on_crate_refill_pressed() -> void:
	if CRATE_PRICE <= GameManager.player_data["coins"]: # if player can purchase
		# payload consists of crate target and cost no type since crates are just crates
		var payload : Dictionary = {
			"target" = "crate",
			"cost" = CRATE_PRICE
		}
		# change scene to refill selection
		SceneManager.change_to("res://scenes/refill_scene/backroom.tscn", payload)

# go to player shop
func _on_player_shop_pressed() -> void:
	SceneManager.change_to("res://scenes/player_shop/main_shop.tscn")

# go to casino
func _on_casino_pressed() -> void:
	SceneManager.change_to("res://scenes/casino/casino_floor.tscn")

# go to crate & barrel
func _on_crate_barrel_pressed() -> void:
	SceneManager.change_to("res://scenes/grid_placement/grid_placement.tscn")
