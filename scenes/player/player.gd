extends CharacterBody2D

class_name Player

## This class represents the player.

## See Inv
var inv: Inv

const SPEED = 100
const DASH_MULT = 2.2
const DASH_DURATION = 0.17
const DASH_COOLDOWN = 0.5
const MAX_COINS = pow(2, 62)

## Represents amount of coins owned by the player
var coins : int
## Represents amount of casino chips owned by the player
var chips : int
## Tracks whether the player is currently dashing or not
var is_dashing : bool = false
## Indicates whether another (shelf) UI is currently open by the player
var other_ui_open: bool = false

## See [AnimatedSprite2D]
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
## After each dash, disables preceding dashes until timeout
@onready var dash_cooldown: Timer = $DashCooldown
## Determines the duration of a dash
@onready var dash_duration: Timer = $DashDuration
## UI element for the player inventory
@export var inv_ui: Control

signal update_coins	## Triggers the coin UI to update on any change to coin amount

## Utilized in the state machine for player movement
enum movement_state {
	IDLE,
	WALK,
	DASH
}

## Maps inventory slot names to their indices
var input_slot_map : Dictionary = {
	"slot_1" : 0,
	"slot_2" : 1,
	"slot_3" : 2,
	"slot_4" : 3,
	"slot_5" : 4,
}

## Tracks current state of player movement
var current_state : movement_state = movement_state.IDLE
## Tracks current direction of player
var last_dir := "down"

func _ready() -> void:
	add_to_group("player")
	if !inv:
		inv = Inv.new(5)
	if inv_ui:
		inv.selected_index = GameManager.player_data["inventory"]["selected_index"] if GameManager.player_data else 0
		inv_ui.inv = inv #links player inventory and respective ui
		inv_ui.allow_hotkeys = true #allows 1-5 use for hotbar-like inv
	coins = GameManager.player_data["coins"] if GameManager.player_data else 0
	chips = GameManager.player_data["chips"] if GameManager.player_data else 0
	#_debug_set_player_inv()

#handles toggled and held inventory
#esc when toggled will close ui not pause
#esc when held will close and pause
#uses keys to enlarge sprites in inventory
func _input(_event: InputEvent) -> void:
	if !inv_ui:
		return
		
	#only for player inventory
	if inv_ui.is_open and inv_ui.allow_hotkeys:
		for key: StringName in input_slot_map:
			if Input.is_action_just_pressed(key):
				var slot : int = input_slot_map[key]

				inv_ui.slots[inv.selected_index].deselect()
				#change slots
				inv.selected_index = slot
				inv_ui.slots[slot].select()

func _physics_process(delta : float)->void:
	if(!other_ui_open):
		move(current_state, delta)
		move_and_slide()

## State machine that tilizes [enum movement_state] to process player movement
func move(curr_state : movement_state, delta : float) -> void:
	match curr_state:
		movement_state.IDLE:
			get_movement_input(delta)
			animated_sprite.speed_scale = 1.0
		movement_state.WALK:
			get_movement_input(delta)
			animated_sprite.speed_scale = 1.0
		movement_state.DASH:
			animated_sprite.speed_scale = DASH_MULT

## Handles keyboard inputs to move the player around the scene and play animations
func get_movement_input(_delta : float) -> void:
	velocity = Vector2.ZERO
	
	var x_dir : float = Input.get_axis("move_left", "move_right")
	var y_dir : float = Input.get_axis("move_up", "move_down")
	velocity = Vector2(x_dir, y_dir)
	
	if velocity != Vector2.ZERO:
		velocity = velocity.normalized() * SPEED
		
		# Determine direction name for animation
		# Appends direction based on directional input
		var anim_dir := ""
		if y_dir < 0:
			anim_dir = "up"
		elif y_dir > 0:
			anim_dir = "down"
		
		if x_dir < 0:
			if anim_dir == "":
				anim_dir = "left"
			else:
				anim_dir += "left"
			animated_sprite.flip_h = false
		elif x_dir > 0:
			if anim_dir == "":
				anim_dir = "left"
			else:
				anim_dir += "left"
			animated_sprite.flip_h = true
		
		last_dir = anim_dir

		var sprint := Input.is_action_just_pressed("sprint")
		if sprint and dash_cooldown.is_stopped():
			dash_duration.start(DASH_DURATION)
			velocity *= DASH_MULT
			current_state = movement_state.DASH
		else:
			current_state = movement_state.WALK

		if anim_dir != "":
			if animated_sprite.sprite_frames.has_animation("walk_" + anim_dir):
				animated_sprite.play("walk_" + anim_dir)
			else:
				animated_sprite.play("walk")
	else:
		current_state = movement_state.IDLE
		if animated_sprite.sprite_frames.has_animation("idle_" + last_dir):
			animated_sprite.play("idle_" + last_dir)
		else:
			animated_sprite.play("default")



func _on_dash_cooldown_timeout() -> void:
	dash_cooldown.stop()

func _on_dash_duration_timeout() -> void:
	dash_duration.stop()
	current_state = movement_state.IDLE
	dash_cooldown.start(DASH_COOLDOWN)

## Getter function for player coins
func get_coins() -> int:
	return coins

## Setter function for player coins, returns new coin amount on successful transaction,
## returns old coin amount on failed transaction
func set_coins(coins_delta : int) -> int:
	var new_coins : int = coins + coins_delta
	if new_coins < 0 or new_coins > MAX_COINS:
		return coins
	coins = new_coins
	update_coins.emit() 
	return new_coins

## Getter function for player chips
func get_chips() -> int:
	return chips

## Setter function for player chips, returns new chip amount on successful transaction,
## returns old chip amount on failed transaction
func set_chips(chips_delta : int) -> int:
	var new_chips : int = chips + chips_delta
	if new_chips < 0 or new_chips > MAX_COINS:
		return chips
	chips = new_chips
	return new_chips


## Return's the player's entire inventory
func get_inventory() -> Inv:
	return inv

## Checks if the player has any empty slot
func has_empty_slot() -> bool:
	for slot in inv.slots:
		if (slot.item == null || slot.item.texture_code == null):
			return true
	return false


## Checks if the player has a slot with [item] and that slot can accept
func can_stack_item(item: InvItem) -> bool:
	for slot in inv.slots:
		if (slot.item.equals(item) and slot.amount < slot.item.max_stack_size):
			return true
	return false
	
## Returns the player's  selected slot
func get_selected_slot() -> InvSlot:
	return inv.get_selected_slot()

## Removes a single item from the player's selected slot
func remove_from_selected() -> void:
	inv.remove_selected()

## Picks up an item and adds to inventory[br]
## Can also be used for collecting items from entities
func collect(item: InvItem) -> bool:
	return inv.insert(item)

## When player blocking UI menu is open
func open_other_ui(flag: bool) -> void:
	if inv_ui and inv_ui.is_open:
		inv_ui.close()
	elif inv_ui and !inv_ui.is_open:
		inv_ui.open()
	other_ui_open = flag

## Retrieves items from entity inventories[br]
## i.e.: bottles from crates or brewed potion from cauldron
func interact_with_entity(entity: Entity)->void:
	var selected_slot:InvSlot = inv.get_selected_slot()
	if selected_slot and selected_slot.item:
		if entity.receive_item(selected_slot.item):
			inv.remove_selected()

## Translates player inventory, coins, and chips into a dictionary for save state
func to_dict()->Dictionary:
	return{
		"inventory": inv.to_dict(),
		"coins": coins,
		"chips": chips
	}

## Translates save state data into player inventory, coins, and chips
func from_dict(data:Dictionary)->void:
	inv.from_dict(data["inventory"])
	coins = data["coins"]
	chips = data["chips"]
	

func _debug_set_player_inv()->void:
	var bottle:InvItem = ItemRegistry.new_item("item_empty_bottle");
	var red:InvItem = ItemRegistry.new_item("item_red_potion");
	inv.insert(bottle)
	inv.insert(red)
	inv.insert(red)
	inv.insert(red)
	inv.insert(red)
	inv.insert(red)
	inv.insert(red)
	
