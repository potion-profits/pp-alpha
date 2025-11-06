extends Entity

@onready var interactable: Area2D = $Interactable
@onready var cauldron_anim: AnimatedSprite2D = $CauldronAnim
@onready var mix_timer: Timer = $MixTimer

@export var animation_name: String = "default"

var held_item: InvItem = null
var mixing: bool = false

const MIX_DURATION := 3.0

func _ready()-> void:
	interactable.interact = _on_interact
	super._ready()
	scene_uid = "res://scenes/cauldron/cauldron.tscn"

func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	if player:
		if !mixing and held_item == null:
			player.interact_with_entity(self)
		if !mixing and held_item:
			if player.collect(held_item):
				held_item = null

func animation_play() -> void:
	if cauldron_anim and cauldron_anim.sprite_frames.has_animation(animation_name):
		cauldron_anim.play(animation_name)
		interactable.is_interactable = false
		print("The player interacted with the cauldron")
	else:
		push_error("AnimatedSprite2D or animation '" + animation_name + "' not found!")


func save()->void:
	save_to_db()

func load_inv_from_db(_id:String)->void:
	pass
	
func save_to_db()->void:
	pass
	
func start_mixing()->void:
	if held_item:
		mixing = true
		if mix_timer:
			mix_timer.wait_time = MIX_DURATION
			mix_timer.start()
		animation_play()


func receive_item(item:InvItem)->bool:
	if not held_item:
		held_item = item
		start_mixing()
		return true
	return false

func _on_mix_timer_timeout() -> void:
	mixing = false
	#held_item = null
	print("Mixing finished for ", held_item.name)
	mix_timer.stop()
