class_name Casino extends Node2D
## Main scene for the casino level that features playable casino games and a cashier.
## The player may exchange coins for chips and chips for prizes / upgrades from the cashier stand.
## See [Player]
@onready var player: Player = $Entities/Player
## UI container for the exchange menu, opens on interact with cashier
@onready var exchange_container: VBoxContainer = $CanvasLayer/ExchangeContainer
## Label for displaying the current pending exchange amount
@onready var num_coins_to_exchange: Label = $CanvasLayer/ExchangeContainer/HBoxContainer/NumCoinsToExchange
## Handles currency and prize exchange, see also [Npc]
@onready var cashier_npc: CharacterBody2D = $StaticAssets/CashierNpc
@onready var spawn_marker: Marker2D = $StaticAssets/MoveTownArea/PlayerSpawn
@onready var dialogue_ui: CanvasLayer = $DialogueUI
## Amount of coins to exchange for chips
var exchange_amt: int = 0

func _ready() -> void:
	# ----- Necessary for pause menu in scene -----
	var pause_scene: Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance: Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	# ----------------------------------------------

	exchange_container.visible = false
	dialogue_ui.action_triggered.connect(_on_dialogue_action)
	dialogue_ui.dialogue_ended.connect(func() -> void:
		exchange_container.visible = false
		player.set_physics_process(true)
	)
	cashier_npc.interactable.interact = open_cashier_dialogue

## Opens dialogue with cashier, branches to exchange or info
func open_cashier_dialogue() -> void:
	var last_dir: String = player.last_dir
	var player_idle_dir: String = "idle_" + last_dir
	player.animated_sprite.play(player_idle_dir)
	player.set_physics_process(false)
	dialogue_ui.open("casino", "cashier_greeting")

## Handles dialogue actions
func _on_dialogue_action(action: String, _data: Dictionary) -> void:
	if action == "open_exchange":
		exchange_amt = 0
		_update_exchange_label(exchange_amt)
		dialogue_ui.show_text("Exchange your coins for chips as needed!")
		exchange_container.visible = true

# exchange logic for coins to chips
func _on_confirm_exchange_pressed() -> void:
	player.set_coins(-exchange_amt)
	player.set_chips(exchange_amt)
	exchange_amt = 0
	_update_exchange_label(exchange_amt)

func _on_cancel_exchange_pressed() -> void:
	exchange_container.visible = false
	dialogue_ui.show_node("anything_else")

func _on_less_coins_pressed() -> void:
	if Input.is_action_pressed("sprint"):
		exchange_amt -= 100
	else:
		exchange_amt -= 10
	if exchange_amt <= 0:
		exchange_amt = 0
	_update_exchange_label(exchange_amt)

func _on_more_coins_pressed() -> void:
	var current: int = player.get_coins()
	if Input.is_action_pressed("sprint"):
		exchange_amt += 100
	else:
		exchange_amt += 10
	if exchange_amt >= current:
		exchange_amt = current - (current % 10)
		# not enough coins label
	_update_exchange_label(exchange_amt)

func _update_exchange_label(new_amt: int) -> void:
	num_coins_to_exchange.text = str(new_amt) + " Coins"

func _on_move_town_area_body_entered(body: Node2D) -> void:
	if body is Player:
		var payload: Dictionary = SceneManager.get_payload()
		payload["player_position"] = spawn_marker.global_position
		SceneManager.change_to("res://scenes/town/town.tscn", payload)

func _on_redeem_pressed() -> void:
	# create sub menu for various prizes (buy a barrel, cauldron, other upgrade)
	pass
