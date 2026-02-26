class_name Casino extends Node2D

## Main scene for the casino level that features playable casino games and a cashier.
## The player may exchange coins for chips and chips for prizes / upgrades from the cashier stand.

## See [Player]
@onready var player: Player = $Player
## UI container for the exchange menu, opens on interact with cashier
@onready var exchange_container: VBoxContainer = $CanvasLayer/ExchangeContainer
## Label for displaying the current pending exchange amount
@onready var num_coins_to_exchange: Label = $CanvasLayer/ExchangeContainer/HBoxContainer/NumCoinsToExchange
## Handles currency and prize exchange, see also [Npc]
@onready var cashier_npc: CharacterBody2D = $CashierNpc
@onready var npcs: Node2D = $Npcs
@onready var dealers: Node2D = $Dealers
@onready var idle_sheet : Resource = preload(
	"res://assets/char_sprites/npc_sprites/npc_customers/rogue_npc_idle.png"
	)
const roaming_npc_scene : PackedScene = preload("res://scenes/npc_alt/roaming_npc.tscn")
const squib_amt : int = 2

var spawn_location_pos : Array = []
## Expects a Node named SpawnLocations to be under the scene's root node that
## holds markers to spawn locations
@onready var spawn_locations: Node2D = $SpawnLocations

## Amount of coins to exchange for chips
var exchange_amt : int = 0
## Used to signal when the player is done exchanging with the cashier
signal end_exchange

func _ready() -> void:
	# ----- Necessary for pause menu in scene -----
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	# ----------------------------------------------
	
	exchange_container.visible = false
	cashier_npc.interactable.interact = process_exchange
	
	for npc : Npc in npcs.get_children():
		npc.sprite.frame = randi_range(0, 3)
		npc.sprite.play("idle_up")
	
	for dealer : Npc in dealers.get_children():
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

## Interact function for the cashier NPC, see interactable for further reference.
## Opens the exchange menu to allow the player to exchange coins for chips and chips for prizes
func process_exchange() -> void:
	player.set_physics_process(false)
	exchange_container.visible = true
	await end_exchange
	exchange_container.visible = false
	player.set_physics_process(true)


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
	npcs.add_child(t_npc)
	npcs.move_child(t_npc, 0)

# exchange logic for coins to chips
func _on_confirm_exchange_pressed() -> void:
	player.set_coins(-exchange_amt)
	player.set_chips(exchange_amt)
	exchange_amt = 0
	_update_exchange_label(exchange_amt)

func _on_cancel_exchange_pressed() -> void:
	end_exchange.emit()

func _on_less_coins_pressed() -> void:
	if Input.is_action_pressed("sprint"):
		exchange_amt -= 100
	else:
		exchange_amt -= 10
	if exchange_amt <= 0:
		exchange_amt = 0
	_update_exchange_label(exchange_amt)

func _on_more_coins_pressed() -> void:
	var current : int = player.get_coins()
	if Input.is_action_pressed("sprint"):
		exchange_amt += 100
	else:
		exchange_amt += 10
	if exchange_amt >= current:
		exchange_amt = current - (current % 10)
		# not enough coins label
	_update_exchange_label(exchange_amt)

func _update_exchange_label(new_amt : int) -> void:
	num_coins_to_exchange.text = str(new_amt) + " Coins"

func _on_move_town_area_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneManager.change_to("res://scenes/town/town.tscn")

func _on_redeem_pressed() -> void:
	# create sub menu for various prizes (buy a barrel, cauldron, other upgrade)
	pass
