class_name Casino extends Node2D
## Main scene for the casino level that features playable casino games and a cashier.
## The player may exchange coins for chips and chips for prizes / upgrades from the cashier stand.
## See [Player]
@onready var player: Player = $Entities/Player
## UI container for the exchange menu, opens on interact with cashier
@onready var exchange_container: VBoxContainer = $DialogueUI/ExchangeContainer
## Label for displaying the current pending exchange amount
@onready var num_coins_to_exchange: Label = $DialogueUI/ExchangeContainer/HBoxContainer/NumCoinsToExchange
## Handles currency and prize exchange, see also [Npc]
@onready var cashier_npc: CharacterBody2D = $StaticAssets/CashierNpc
@onready var spawn_marker: Marker2D = $StaticAssets/MoveTownArea/PlayerSpawn
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var ysort: Node2D = $"Entities"
@onready var idle_sheet : Resource = preload(
	"res://assets/char_sprites/npc_sprites/npc_customers/rogue_npc_idle.png"
	)
const roaming_npc_scene : PackedScene = preload("res://scenes/npc_alt/roaming_npc.tscn")
const squib_amt : int = 2

var spawn_location_pos : Array = []
## Expects a Node named SpawnLocations to be under the scene's root node that
## holds markers to spawn locations
@onready var spawn_locations: Node2D = $StaticAssets/SpawnLocations
## Amount of coins to exchange for chips
var exchange_amt: int = 0

func _ready() -> void:
	exchange_container.visible = false
	dialogue_ui.action_triggered.connect(_on_dialogue_action)
	dialogue_ui.dialogue_ended.connect(func() -> void:
		exchange_container.visible = false
		player.set_physics_process(true)
	)
	cashier_npc.interactable.interact = open_cashier_dialogue
	
	for npc : Node in ysort.get_children():
		if npc.name.begins_with('Npc'):
			npc.sprite.frame = randi_range(0, 3)
			npc.sprite.play("idle_up")
	
	for dealer : Node in ysort.get_children():
		if dealer.name.begins_with("Dealer"):
			dealer.sprite.sprite_frames = dealer.build_sprite_frames(idle_sheet, null)
			dealer.npc_class = "rogue"
			dealer.sprite.frame = randi_range(0, 3)
			dealer.sprite.play("idle_down")
	
	for location : Marker2D in spawn_locations.get_children():
		spawn_location_pos.append(location.position)
	spawn_roaming_npcs()

"""
# I want the player to be able to use buttons to signal, but process runs faster than the interact
# resulting in race conditions
func _process(_delta : float) -> void:
	if exchange_container.visible and (
		Input.is_action_pressed("interact") or Input.is_key_pressed(KEY_ESCAPE)):
			end_exchange.emit()
"""

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

func spawn_roaming_npcs()->void:
	for location : Vector2 in spawn_location_pos:
		location = squib(location)
		spawn_npc(location)

func squib(loc : Vector2) -> Vector2:
	var off1 : int = randi_range(-squib_amt,squib_amt)
	var off2 : int = randi_range(-squib_amt,squib_amt)
	
	return loc + Vector2(off1, off2)

func spawn_npc(loc: Vector2) -> void:
	var t_npc : RoamingNpc = roaming_npc_scene.instantiate()
	t_npc.position = loc
	ysort.add_child(t_npc)

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
