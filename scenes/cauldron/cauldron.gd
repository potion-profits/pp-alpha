extends Entity	#will help store placement and inventory information for persistence

#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable

#cauldron specific references
@onready var cauldron_anim: AnimatedSprite2D = $CauldronAnim
@onready var mix_timer: Timer = $MixTimer
@export var animation_name: String = "default"

var mixing: bool = false
const MIX_DURATION := 3.0

func _ready()-> void:
	#links interactable template to cauldron specific method (needed for all interactables)
	interactable.interact = _on_interact
	#sets up entity info 
	super._ready()
	#used to find out what actual scene to place in entity manager
	entity_code = "cauldron"
	if !inv:
		inv = Inv.new(1)

#Handles player interaction with cauldron when appropriate
func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	#makes sure interaction is from a player
	if player:
		if !mixing and inv.slots[0].item == null:	#can mix something
			player.interact_with_entity(self)	#call player interaction which calls receive_item
		if !mixing and inv.slots[0].item:	#something is in the cauldron waiting to be picked up
			if player.collect(inv.slots[0].item):
				inv.slots[0].amount-=1	#the player collected, so remove item from cauldron
				inv.slots[0].item = null

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
	if inv.slots[0].item:
		mixing = true
		if mix_timer:
			mix_timer.wait_time = MIX_DURATION
			mix_timer.start()
		animation_play()

#Prompts cauldron to take an item. If success, start mixing. Else, return false
func receive_item(item:InvItem)->bool:
	if not inv.slots[0].item and item.mixable:
		inv.slots[0].item = item._duplicate()
		inv.slots[0].amount +=1
		start_mixing()
		return true
	return false

#when the timer runs out, change the item held to be done and stop the timer
func _on_mix_timer_timeout() -> void:
	mixing = false
	inv.slots[0].item.mixable = false
	inv.slots[0].item.sellable = true
	#held_item = null
	print("Mixing finished for ", inv.slots[0].item.name)
	mix_timer.stop()
#
func to_dict()-> Dictionary:
	var mix_timer_left :float = mix_timer.time_left if mix_timer and mixing else 0.0
	var cauldron_state:Dictionary = {
		"mixing":mixing,
		"mix_timer_time_left": mix_timer_left
	}
	cauldron_state.merge(super.to_dict())
	return cauldron_state

func from_dict(data:Dictionary)->void:
	super.from_dict(data)
	mixing = data["mixing"]
	var time_left:float = data["mix_timer_time_left"]
	if time_left > 0.0:
		call_deferred("_restore_timer", time_left)

func _restore_timer(time_left: float)->void:
	if mix_timer:
		mix_timer.stop()
		mix_timer.start(time_left)
