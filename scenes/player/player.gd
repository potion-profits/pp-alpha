extends CharacterBody2D

class_name Player
#the resource that will be used to make an inventory (player_inventory.tres)
var inv: Inv

const SPEED = 150
const DASH_MULT = 2.2
const DASH_DURATION = 0.17
const DASH_COOLDOWN = 0.5
const MAX_COINS = pow(2, 62)

var coins : int = 500 # replace value with db call once implemented
var chips : int = 10 # replace value with db call once implemented
var is_dashing : bool = false
var other_ui_open: bool = false # when a ui menu is open, restrict player movement

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_cooldown: Timer = $DashCooldown
@onready var dash_duration: Timer = $DashDuration
@onready var inv_ui:Control = $Inv_UI

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
	inv_ui.inv = inv #links player inventory and respective ui
	inv_ui.allow_hotkeys = true #allows 1-5 use for hotbar-like inv
	_debug_set_player_inv()

#handles toggled and held inventory
#esc when toggled will close ui not pause
#esc when held will close and pause
#uses keys to enlarge sprites in inventory
func _input(event: InputEvent) -> void:
	if !other_ui_open:
		if inv_ui.inventory_toggle:
			if inv_ui.is_open:
				if event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel"):
					get_viewport().set_input_as_handled()
					inv_ui.close()
			else:
				if event.is_action_pressed("inventory"):
					inv_ui.open()
		else:
			if event.is_action_pressed("inventory") and !inv_ui.is_open:
				inv_ui.open()
			elif (event.is_action_released("inventory") or event.is_action_pressed("ui_cancel")) and inv_ui.is_open:
				inv_ui.close()
			
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
	if(!other_ui_open):
		move(current_state, delta)
		move_and_collide(velocity)
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
	return new_coins

func get_chips() -> int:
	return chips

func set_chips(chips_delta : int) -> int:
	var new_chips : int = chips + chips_delta
	if new_chips < 0 or new_chips > MAX_COINS:
		return chips
	chips = new_chips
	return new_chips
	
#called to pick up an item and add to player inventory
func collect(item: InvItem) -> bool:
	return inv.insert(item)

func get_inventory() -> Inv:
	return inv
	
func open_other_ui(flag: bool) -> void:
	if inv_ui.is_open:
		inv_ui.close()
	other_ui_open = flag

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
	
