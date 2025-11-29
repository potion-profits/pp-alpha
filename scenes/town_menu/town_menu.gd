extends Control

@onready var barrels : VBoxContainer = $TabContainer/Barrels

var barrel_type_mapping : Dictionary = {
	"R": "red_barrel",
	"B": "blue_barrel",
	"G": "green_barrel",
	"D": "dark_barrel"
}

var barrel_prices : Dictionary = {
	"R" : 50,
	"G" : 75,
	"B" : 100,
	"D" : 500
}

const BARREL_MAX_CAP = 1000
const CRATE_MAX_CAP = 64
const CRATE_PRICE = 100


func _ready() -> void:
	for button : Button in barrels.get_children():
		button.pressed.connect(_on_barrels_refill_pressed.bind(button.name))
		pass

func _on_barrels_refill_pressed(button_name: String) -> void:
	var button_key: String = button_name[0]
	var coins: int = GameManager.player_data["coins"]
	var price: int = barrel_prices[button_key]
	if price <= coins:
		for entity: Dictionary in GameManager.runtime_entities["MainShop"]:
			if entity["entity_code"] == "barrel" and entity["ml"] < 100:
				entity["ml"] = BARREL_MAX_CAP
				entity["barrel_id"] = barrel_type_mapping[button_key]
				GameManager.player_data["coins"] -= price
				break

func _on_crate_refill_pressed() -> void:
	if CRATE_PRICE <= GameManager.player_data["coins"]:
		for entity:Dictionary in GameManager.runtime_entities["MainShop"]:
			if entity["entity_code"] == "crate" and entity["bottles"]<25:
				entity["bottles"] = CRATE_MAX_CAP
				GameManager.player_data["coins"] -= CRATE_PRICE
				break


func _on_player_shop_pressed() -> void:
	GameManager.connect_scene_load_callback()
	get_tree().change_scene_to_file("res://scenes/player_shop/main_shop.tscn")


func _on_casino_pressed() -> void:
	GameManager.connect_scene_load_callback()
	get_tree().change_scene_to_file("res://scenes/casino/casino_menu.tscn")
