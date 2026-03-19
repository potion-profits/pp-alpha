extends Node2D

@onready var player: Player = $"y-sort/Player"
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var camera: Camera2D = $"y-sort/Player/Camera2D"
@onready var elevator: Elevator = $Static/Elevator
@onready var guard_interact: Area2D = $Static/GuardInteract
@onready var guard_collide: CollisionShape2D = $Static/Guards/CollisionShape2D2
@onready var guard: CharacterBody2D = $"y-sort/Guard"
@onready var limit_marker: Marker2D = $LimitMarker
@onready var shark_desk: StaticBody2D = $"y-sort/SharkDesk"
@onready var pay_container: VBoxContainer = $DialogueUI/PayContainer
@onready var num_coins_to_pay: Label = $DialogueUI/PayContainer/HBoxContainer/NumCoinsToPay
@onready var confirm_pay: Button = $DialogueUI/PayContainer/ConfirmPay
@onready var black: TextureRect = $BlackScreen
@onready var timer: Timer = $Timer

var egg : bool = false
var egg_seen : bool = false
var trophy : bool = false
var guard_blocking: bool = false
var move_guard: bool = false
var post_up : bool = false
var move_delta : float = 0
var init_guard1_pos : Vector2 
var block_limit : float 
var exchange_amt : int = 0
var loan_action :bool = false

func _ready() -> void:
	camera.reset_smoothing()
	elevator.set_floor(1)
	dialogue_ui.action_triggered.connect(_on_dialogue_action)
	elevator.interactable.interact = open_elevator_dialogue
	shark_desk.interactable.interact = open_shark_dialogue
	init_guard1_pos = guard.position
	block_limit = limit_marker.position.x
	if not player.first_office:
		guard_collide.disabled = true
		guard_interact.hide()
	black.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action("interact"):
		if egg and not egg_seen:
			egg_seen = true
			prep_dialogue_open()
			dialogue_ui.open("penthouse", "egg")
		if trophy:
			prep_dialogue_open()
			dialogue_ui.open("penthouse", "trophy")
	

func _physics_process(delta: float) -> void:
	if move_guard:
		var target_x : float = player.position.x
		if player.position.x < block_limit:
			target_x = block_limit
		move_delta += delta
		var gx : float = guard.position.x
		guard.position.x = gx + (target_x - gx)*move_delta
		if guard.position.x == target_x:
			move_guard = false
			move_delta = 0
	
	if post_up:
		move_delta += delta
		var gp : Vector2 = guard.position
		guard.position = gp + (init_guard1_pos - gp)*move_delta
		if guard.position == init_guard1_pos:
			post_up = false
			move_delta = 0

	if guard_blocking:
		if player.position.x > block_limit:
			guard.position.x = player.position.x
		else:
			guard.position.x = block_limit
	

func prep_dialogue_open() ->void:
	var last_dir: String = player.last_dir
	var player_idle_dir: String = "idle_" + last_dir
	player.animated_sprite.play(player_idle_dir)
	player.set_physics_process(false)

func open_elevator_dialogue() -> void:
	prep_dialogue_open()
		
	if player.first_shark:
		dialogue_ui.open("penthouse", "no_leaving")
	elif GameManager.lost_game:
		dialogue_ui.open("cant_do", "end_block")
	else:
		dialogue_ui.open("elevator","penthouse_prompt")
	
func open_shark_dialogue() -> void:
	prep_dialogue_open()
	
	# Play SFX on dialogue open only
	
	if GameManager.lost_game:
		dialogue_ui.open("penthouse","not_paid")
	
	if player.first_shark:
		dialogue_ui.open("penthouse", "init_shark")
	else:
		dialogue_ui.open("penthouse", "shark_prompt")
	
func _on_dialogue_action(action: String, _data: Dictionary) -> void:
	match action:
		"elevator_enter":
			dialogue_ui.close()
			play_elevator_down()
		"enter_office":
			move_to_post()
			dialogue_ui.close()
			office_checked()
		"block_office":
			dialogue_ui.close()
			guard_blocking = true
		"move_to_block":
			move_to_block()
		"coins_100":
			player.set_coins(+100)
		"first_shark_done":
			player.first_shark = false
			dialogue_ui.close()
			player.debt = 2100
		"pay_debt":
			loan_action = false
			confirm_pay.text = "Pay"
			dialogue_ui.show_text("Your loan balance is : "+ str(player.debt) +". How much do you want to pay?")
			pay_container.visible = true
		"get_loan":
			loan_action = true
			confirm_pay.text = "Borrow"
			dialogue_ui.show_text("Your loan balance is : "+ str(player.debt) + ". How much do you want to borrow?")
			pay_container.visible = true
		"unlock_barrier":
			GameManager.credits_flag = true
			dialogue_ui.close()
		"lose_state":
			black.visible = true
			dialogue_ui.show_text("*CHOMP*")
			timer.start(3)

func move_to_block()->void:
	move_guard = true

func move_to_post()->void:
	guard_blocking = false
	post_up = true

func office_checked()->void:
	player.first_office = false
	guard_collide.disabled = true
	guard_interact.hide()
	
func play_elevator_down()->void:
	player.set_physics_process(false)
	elevator.start_anim()


func _on_window_interact_body_entered(body: Node2D) -> void:
	if( body is Player and 
	TimeManager.day > 1 and 
	TimeManager.day % 4 == 0 and 
	egg_seen == false):
		egg = true


func _on_window_interact_body_exited(body: Node2D) -> void:
	if body is Player:
		egg = false


func _on_trophy_interact_body_entered(body: Node2D) -> void:
	if body is Player:
		trophy = true


func _on_trophy_interact_body_exited(body: Node2D) -> void:
	if body is Player:
		trophy = false


func _on_guard_interact_body_entered(body: Node2D) -> void:
	if body is Player and player.first_office == true:
		prep_dialogue_open()
		dialogue_ui.open("penthouse", "initial_guards")


func _on_confirm_pay_pressed() -> void:
	if loan_action:
		exchange_amt *= -1
	player.set_coins(-exchange_amt)
	player.debt -= exchange_amt
	exchange_amt = 0
	_update_exchange_label(exchange_amt)
	if player.debt <= 0:
		player.debt = 0
		loan_paid_off()
		return
	if loan_action:
		dialogue_ui.show_text("Your loan balance is : "+ str(player.debt) +". How much do you want to borrow?")
	else:
		dialogue_ui.show_text("Your loan balance is : "+ str(player.debt) +". How much do you want to pay?")

func loan_paid_off()->void:
	exchange_amt = 0
	_update_exchange_label(exchange_amt)
	pay_container.visible = false
	dialogue_ui.show_node("loan_complete")

func _on_cancel_pay_pressed() -> void:
	exchange_amt = 0
	_update_exchange_label(exchange_amt)
	pay_container.visible = false
	dialogue_ui.show_node("anything_else")

func _on_less_coins_pressed() -> void:
	if Input.is_action_pressed("dash"):
		exchange_amt -= 100
	else:
		exchange_amt -= 10
	if exchange_amt <= 0:
		exchange_amt = 0
	_update_exchange_label(exchange_amt)

func _on_more_coins_pressed() -> void:
	var current : int = player.get_coins()
	if Input.is_action_pressed("dash"):
		exchange_amt += 100
	else:
		exchange_amt += 10
	if exchange_amt >= current and not loan_action:
		exchange_amt = current - (current % 10)
	if exchange_amt > player.debt and not loan_action:
		exchange_amt = player.debt
		# not enough coins label
	_update_exchange_label(exchange_amt)

func _update_exchange_label(new_amt : int) -> void:
	num_coins_to_pay.text = str(new_amt) + " Coins"

func _on_timer_timeout() -> void:
	dialogue_ui.close()
	GameManager.lost_game = false
	get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")
