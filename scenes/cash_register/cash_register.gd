extends Node2D

## Handles interaction with the cash register
##
## Has members and methods to deal with multiple NPCs, transactions, and 
## displaying a ready to checkout icon

var player: Player	## Holds the player when possible
var queue : Array[Npc] = []	## Queue of NPCs that are ready to checkout
var bob_time: float = 0.0	## Time that the icon has been bobbing
var base_icon_y: float	## The position of the icon
var bob_speed: float = 2.5	## The speed at which the icon should bob
var bob_height: float = 2.0	## How much the icon should bob

@onready var cust_waiting_icon: Sprite2D = $CustWaitingIcon	## Ready to checkout icon
@onready var sale_sfx : AudioStreamPlayer2D = $SaleSFX ## Reference to audio stream for sound effects

func _ready() -> void:
	cust_waiting_icon.visible = false
	base_icon_y = cust_waiting_icon.position.y

func _process(delta: float) -> void:
	if cust_waiting_icon.visible:
		bob_time += delta
		cust_waiting_icon.position.y = base_icon_y + sin(bob_time * bob_speed) * bob_height

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and len(queue) > 0 and player: # and curr_npc and player and not curr_npc.is_checked_out:
		var curr_npc : ShopNpc = queue.pop_front()
		
		curr_npc.is_checked_out = true
		curr_npc.checkout_timer.timeout.emit()
		
		# Get NPC's potion
		var potion: String = curr_npc.get_preferred_item()
		
		# Get sell price of the potion
		var gold: int = ItemRegistry.get_item_price(potion)
		
		player.set_coins(gold)
		
		# play sound effect on interact
		sale_sfx.play()
		
		if (len(queue) == 0):
			cust_waiting_icon.visible = false


func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
	if body is Npc and body.current_action == body.action.CHECKOUT and not body.is_checked_out:
		queue.push_back(body)
		cust_waiting_icon.visible = true


func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
	if body is Npc and body.current_action == body.action.LEAVE:
		var idx : int = queue.find(body)
		if (idx != -1):
			queue.pop_at(idx)
			
		if cust_waiting_icon.visible and len(queue) == 0:
			cust_waiting_icon.visible = false
