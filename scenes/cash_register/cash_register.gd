extends Node2D

var player: Player
var curr_npc : Npc
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
	if event.is_action_pressed("interact") and curr_npc and player and not curr_npc.is_checked_out:
		curr_npc.is_checked_out = true
		curr_npc.checkout_timer.timeout.emit()
		print("+50 gold\n")
		player.set_coins(50)
		cust_waiting_icon.visible = false


func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
	if body is Npc and body.current_action == body.action.CHECKOUT and not body.is_checked_out:
		curr_npc = body
		cust_waiting_icon.visible = true


func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
	if body is Npc and body.current_action == body.action.LEAVE:
		curr_npc = null
		if cust_waiting_icon.visible:
			cust_waiting_icon.visible = false
