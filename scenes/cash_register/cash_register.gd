extends Node2D

var player: Player
var queue : Array[Npc] = []
var bob_time: float = 0.0
var base_icon_y: float
var bob_speed: float = 2.5
var bob_height: float = 2.0

@onready var cust_waiting_icon: Sprite2D = $CustWaitingIcon

func _ready() -> void:
	cust_waiting_icon.visible = false
	base_icon_y = cust_waiting_icon.position.y

func _process(delta: float) -> void:
	if cust_waiting_icon.visible:
		bob_time += delta
		cust_waiting_icon.position.y = base_icon_y + sin(bob_time * bob_speed) * bob_height

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and len(queue) > 0 and player: # and curr_npc and player and not curr_npc.is_checked_out:
		var curr_npc : Npc = queue.pop_front()
		
		curr_npc.is_checked_out = true
		curr_npc.checkout_timer.timeout.emit()
		player.set_coins(50)
		
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
