class_name ReturnBasket extends Entity

@onready var interactable: Area2D = $Interactable
@onready var basket_sprite: Sprite2D = $BasketSprite
@onready var empty_basket_sprite: Sprite2D = $EmptyBasketSprite

var all_items : Array = []

func _ready()-> void:
	#links interactable template to cauldron specific method (needed for all interactables)
	interactable.interact = _on_interact
	
	#sets up entity info 
	super._ready()
	#used to find out what actual scene to place in entity manager
	entity_code = "basket"

func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	if player:
		if all_items:
			var returned_item : InvItem = all_items[-1]
			if player.collect(returned_item):
				all_items.pop_back()
		else:
			basket_sprite.hide()
			await get_tree().create_timer(0.3).timeout
			basket_sprite.show()

func return_item(r_item : InvItem) -> void:
	all_items.push_back(r_item)

func from_dict(data:Dictionary)->void:
	super.from_dict(data)
	if data.has("items") and len(data["items"]) > 0:
		for item : Dictionary in data["items"]:
			var temp_item : InvItem = InvItem.new()
			temp_item.from_dict(item)
			all_items.append(temp_item)

func to_dict()-> Dictionary:
	var item_info_arr : Array = []
	for item : InvItem in all_items:
		item_info_arr.append(item.to_dict())

	var return_items:Dictionary = {
		"items": item_info_arr
	}
	return_items.merge(super.to_dict())
	return return_items
