extends Entity	#will help store placement and inventory information for persistence

## Handles cauldron functionality and visual representation.
##
## Includes methods to handle player interactions, animations, functionality, 
## and saving/loading the state.
 
#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable ## Reference to interactable component

#cauldron specific references
@onready var cauldron_anim: AnimatedSprite2D = $CauldronAnim ## Animated Sprite Reference
@onready var mix_timer: Timer = $MixTimer	## Reference to mixing timer
@onready var progress_bar: TextureProgressBar = $ProgressBar	## Reference to progress bar
@onready var mix_sfx: AudioStreamPlayer2D = $MixSFX ## Reference to audio stream for sound effects
@export var animation_name: String = "default"	## Cauldron animation name

var mixing: bool = false	## Keeps track of the cauldron's state
const MIX_DURATION : float = 3.0
const CAULDRON_TOOLTIP : String = "Press E to Brew Potion"

func _ready()-> void:
	#links interactable template to cauldron specific method (needed for all interactables)
	interactable.interact = _on_interact
	interactable.tooltip = CAULDRON_TOOLTIP
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

## Safely plays the cauldron's mixing animation
func animation_play() -> void:
	if cauldron_anim and cauldron_anim.sprite_frames.has_animation(animation_name):
		cauldron_anim.play(animation_name)
		interactable.is_interactable = false
	else:
		push_error("AnimatedSprite2D or animation '" + animation_name + "' not found!")

## Safely stops the cauldron's mixing animation
func animation_stop() -> void:
	if cauldron_anim and cauldron_anim.sprite_frames.has_animation(animation_name):
		cauldron_anim.stop()
	else:
		push_error("AnimatedSprite2D or animation '" + animation_name + "' not found!")
	
## Handles switching the state of the cauldron to mixing, 
## including playing the animation, displaying the progress bar, and playing mixing SFX.
func start_mixing()->void:
	if inv.slots[0].item:
		mixing = true
		if mix_timer:
			mix_timer.wait_time = MIX_DURATION
			mix_timer.start()
			progress_bar.visible = true
		animation_play()
		# Loop sfx while mixing
		if mix_sfx:
			mix_sfx.stream_paused = false
			mix_sfx.play()

## Checks if the cauldron can take in the given item and starts mixing 
## if successful. See [method start_mixing].[br][br]
##
## Returns true when [param item] is mixable InvItem and the 
## cauldron is not holding something else.
func receive_item(item:InvItem)->bool:
	if not inv.slots[0].item and item.mixable:
		inv.slots[0].item = item._duplicate()
		inv.slots[0].amount +=1
		start_mixing()
		return true
	return false

#when the timer runs out, change the item held to be done and stop the timer
func _on_mix_timer_timeout() -> void:
	animation_stop()
	mixing = false
	inv.slots[0].item.mixable = false
	inv.slots[0].item.sellable = true
	progress_bar.visible = false
	progress_bar.value = 100
	mix_timer.stop()
	# stop looping sfx once timer runs out
	if mix_sfx:
		mix_sfx.stop()
	
func _process(_delta: float) -> void:
	if mixing:
		var progress_fill: float = (mix_timer.time_left / MIX_DURATION) * 100
		progress_bar.value = progress_fill

## Creates and returns a dictionary representation of this cauldron. See also [method from_dict].
func to_dict()-> Dictionary:
	var mix_timer_left :float = mix_timer.time_left if mix_timer and mixing else 0.0
	var cauldron_state:Dictionary = {
		"mixing":mixing,
		"mix_timer_time_left": mix_timer_left,
	}
	cauldron_state.merge(super.to_dict())
	return cauldron_state

## Reconstructs a cauldron with the given data.[br][br]
##
## Expects [param data] to have mixing and mix_timer_time_left keys. See also [method to_dict].
func from_dict(data:Dictionary)->void:
	super.from_dict(data)
	mixing = data["mixing"]
	var time_left:float = data["mix_timer_time_left"]
	if time_left > 0.0:
		call_deferred("_restore_timer", time_left)

# Restores the cauldron's timer state after loading
func _restore_timer(time_left: float)->void:
	if mix_timer:
		progress_bar.value = (time_left/MIX_DURATION) * 100
		progress_bar.visible = true
		mix_timer.stop()
		mix_timer.start(time_left)
