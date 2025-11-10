extends Entity	#will help store placement and inventory information for persistence

#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable

#cauldron specific references
@onready var cauldron_anim: AnimatedSprite2D = $CauldronAnim
@onready var mix_timer: Timer = $MixTimer
@export var animation_name: String = "default"

#holds an item, will likely need to change to an inventory of size 1 later
var held_item: InvItem = null
var mixing: bool = false

const MIX_DURATION := 3.0

func _ready()-> void:
	#links interactable template to cauldron specific method (needed for all interactables)
	interactable.interact = _on_interact
	#sets up entity info 
	super._ready()
	#sets entity.scene_uid to this, will change to code and have entity manager handle scenes
	scene_uid = "res://scenes/cauldron/cauldron.tscn"

#Handles player interaction with cauldron when appropriate
func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	#makes sure interaction is from a player
	if player:
		if !mixing and held_item == null:	#can mix something
			player.interact_with_entity(self)	#call player interaction which calls receive_item
		if !mixing and held_item:	#something is in the cauldron waiting to be picked up
			if player.collect(held_item):	#the player collected, so remove item from cauldron
				held_item = null

#plays animation
func animation_play() -> void:
	if cauldron_anim and cauldron_anim.sprite_frames.has_animation(animation_name):
		cauldron_anim.play(animation_name)
		interactable.is_interactable = false
		print("The player interacted with the cauldron")
	else:
		push_error("AnimatedSprite2D or animation '" + animation_name + "' not found!")

#not implemented
func save()->void:
	save_to_db()

#not implemented
func load_inv_from_db(_id:String)->void:
	pass

#not implemented
func save_to_db()->void:
	pass
	
#mixes item for MIX_DURATION amount of time
func start_mixing()->void:
	if held_item:
		mixing = true
		if mix_timer:
			mix_timer.wait_time = MIX_DURATION
			mix_timer.start()
		animation_play()

#Prompts cauldron to take an item. If success, start mixing. Else, return false
func receive_item(item:InvItem)->bool:
	if not held_item and item.mixable:
		held_item = item._duplicate()
		start_mixing()
		return true
	return false

#when the timer runs out, change the item held to be done and stop the timer
func _on_mix_timer_timeout() -> void:
	mixing = false
	held_item.mixable = false
	held_item.sellable = true
	#held_item = null
	print("Mixing finished for ", held_item.name)
	mix_timer.stop()
