extends CharacterBody2D

class_name Player
#the resource that will be used to make an inventory (player_inventory.tres)
var inv: Inv

const SPEED = 100
const DASH_MULT = 2.2
const DASH_DURATION = 0.17
const DASH_COOLDOWN = 0.5
const MAX_COINS = pow(2, 62)

var coins : int
var chips : int
var is_dashing : bool = false
var can_move : bool = true

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_cooldown: Timer = $DashCooldown
@onready var dash_duration: Timer = $DashDuration
@export var inv_ui: Control

signal update_coins

enum movement_state {
	IDLE,
	WALK,
	DASH
}

#updated to use input map in project settings
var input_slot_map : Dictionary = {
	"slot_1" : 0,
	"slot_2" : 1,
	"slot_3" : 2,
	"slot_4" : 3,
	"slot_5" : 4,
}

var current_state : movement_state = movement_state.IDLE
var last_dir := "down"

#sets up player inventory on each run
func _ready() -> void:
	add_to_group("player")
	if !inv:
		inv = Inv.new(5)
	if inv_ui:
		inv_ui.inv = inv #links player inventory and respective ui
		inv_ui.allow_hotkeys = true #allows 1-5 use for hotbar-like inv
	coins = GameManager.player_data["coins"] if GameManager.player_data else 0
	chips = GameManager.player_data["chips"] if GameManager.player_data else 0
	#_debug_set_player_inv()

#handles toggled and held inventory
#esc when toggled will close ui not pause
#esc when held will close and pause
#uses keys to enlarge sprites in inventory
func _input(event: InputEvent) -> void:
	if !inv_ui:
		return
		
	#only for player inventory
	if inv_ui.is_open and inv_ui.allow_hotkeys:
		for key: StringName in input_slot_map:
			if Input.is_action_just_pressed(key):
				var slot : int = input_slot_map[key]
				#if something already selected, deselect
				if inv.selected_index !=-1:
					inv_ui.slots[inv.selected_index].deselect()
				#change slots
				if inv.selected_index != slot:
					inv.selected_index = slot
					inv_ui.slots[slot].select()
				#deselect current slot
				else:
					inv.selected_index = -1

func _physics_process(delta : float)->void:
	if(can_move):
		move(current_state, delta)
		move_and_slide()

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

# Updated function for 8 directional movement
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

# update getters/setters for currency once db is implemented
func get_coins() -> int:
	return coins

func set_coins(coins_delta : int) -> int:
	var new_coins : int = coins + coins_delta
	if new_coins < 0 or new_coins > MAX_COINS:
		return coins
	coins = new_coins
	update_coins.emit() 
	return new_coins

func get_chips() -> int:
	return chips

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

## Picks up an item and adds to inventory
## Can also be used for collecting items from entities
func collect(item: InvItem) -> bool:
	return inv.insert(item)

## When a ui menu is open, restrict player movement and close inv_ui
func open_other_ui() -> void:
	if inv_ui and !inv_ui.is_open:
		inv_ui.open()
		can_move = false

func close_other_ui() -> void:
	if inv_ui and inv_ui.is_open:
		inv_ui.close()
		can_move = true

func interact_with_entity(entity: Entity)->void:
	var selected_slot:InvSlot = inv.get_selected_slot()
	if selected_slot and selected_slot.item:
		if entity.receive_item(selected_slot.item):
			inv.remove_selected()

func to_dict()->Dictionary:
	return{
		"inventory": inv.to_dict(),
		"coins": coins,
		"chips": chips
	}

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
	
