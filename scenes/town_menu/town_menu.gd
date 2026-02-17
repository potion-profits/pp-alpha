extends Control

## Handles scene transitions to different locations and refills.
##
## Simulates a town where the player can enter a shop that refills shop supplies,
## the casino, or go to the player shop. 
##
## @experimental: Handles a simluated town but will be replaced with an actual town scene.

# go back to town
func _on_town_pressed() -> void:
	SceneManager.change_to("res://scenes/supply_shop/supply_shop.tscn")


func _on_refill_pressed() -> void:
	SceneManager.change_to("res://scenes/refill_scene/backroom.tscn")

func _on_placement_pressed() -> void:
	SceneManager.change_to("res://scenes/grid_placement/grid_placement.tscn")
