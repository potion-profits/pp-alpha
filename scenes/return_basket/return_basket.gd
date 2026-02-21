class_name ReturnBasket extends Entity

@onready var interactable: Area2D = $Interactable
@onready var basket_sprite: Sprite2D = $BasketSprite

var all_items : Array = []

func _ready()-> void:
	#links interactable template to cauldron specific method (needed for all interactables)
	interactable.interact = _on_interact
	
	#sets up entity info 
	super._ready()
	#used to find out what actual scene to place in entity manager
	entity_code = "basket"

func _on_interact()->void:
	if all_items:
		var returned_item : InvItem = all_items.pop_back()
		print("Box had: ", returned_item)
		
	else:
		basket_sprite.modulate = Color("Red")
		await get_tree().create_timer(0.3).timeout
		basket_sprite.modulate = Color("00977c")

func return_item(r_item : InvItem) -> void:
	all_items.push_back(r_item)

func from_dict(data:Dictionary)->void:
	super.from_dict(data)
	if data.has("items") and len(data["items"]) > 0:
		all_items = data["items"]

func to_dict()-> Dictionary:
	var return_items:Dictionary = {
		"items": all_items
	}
	return_items.merge(super.to_dict())
	return return_items
