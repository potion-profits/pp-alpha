extends Area2D

@export var animation_name: String = "default"  # Name of animation to play

var held_item: InvItem = null
var held_amount: int = 0
var mixing: bool = false

@onready var animated_sprite: AnimatedSprite2D = get_parent().get_node("CauldronAnim")
@onready var mix_timer: Timer = $MixTimer

const MIX_DURATION := 3.0

##lets player interact if in the area
#func _input(event: InputEvent) -> void:
	#

func start_mixing()->void:
	if held_item:
		mixing = true
		if mix_timer:
			mix_timer.wait_time = MIX_DURATION
			mix_timer.start()
		animation_play()

##tracks when player is in area and sets the player
#func _on_interactable_area_body_entered(body: Node) -> void:
	#if body.name == "Player":
		#player = body
		#player_in_area = true
#
##tracks when player leaves area
#func _on_interactable_area_body_exited(body : Node) -> void:
	#if body.name == "Player":
		#player_in_area = false
		
#on interact, animation plays on sprite
func animation_play() -> void:
	if animated_sprite and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)
	else:
		push_error("AnimatedSprite2D or animation '" + animation_name + "' not found!")

#func save()->void:
	#pass

func receive_item(item:InvItem, amount:int)->bool:
	if not held_item:
		held_item = item
		held_amount = amount
		start_mixing()
		return true
	return false

func _on_mix_timer_timeout() -> void:
	mixing = false
	#held_item = null
	print("Mixing finished for ", held_item.name)
	mix_timer.stop()
