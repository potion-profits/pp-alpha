extends Node2D

## Handles NPC spawning and UI elements within the main shop scene

## Reference to scene's AstarGrid/floor tilemap, see astar.gd
@onready var floor_map : Node2D = $FrontRoom/AstarTilemap
## Marker for player transition to frontroom
@onready var frontroom_backdoor_dest_marker: Marker2D = $FrontRoom/frontroom_backdoor_dest_marker
## Marker for player transition to backroom
@onready var backroom_frontdoor_dest_marker: Marker2D = $BackRoom/backdoor_frontroom_dest_marker
## Camera centered on player
@onready var player_camera: Camera2D = $EntityManager/Player/Camera2D
## Top left corner of frontroom
@onready var f_top_left: Marker2D = $FrontRoom/FrontRoomEdges/TopLeft
## Bottom right corner of frontroom
@onready var f_bottom_right: Marker2D = $FrontRoom/FrontRoomEdges/BottomRight
## Top left corner of backroom
@onready var b_top_left: Marker2D = $BackRoom/BackRoomEdges/TopLeft
## Bottom right corner of backroom
@onready var b_bottom_right: Marker2D = $BackRoom/BackRoomEdges/BottomRight
## Coin UI element
@onready var static_ui: CanvasLayer = $Static_UI
## Inventory UI element
@onready var inv_ui: Control = $Static_UI/Inv_UI
## Scene's [EntityManager]
@onready var entity_manager: EntityManager = $EntityManager

@onready var tutorial_ui: CanvasLayer = $Tutorial_UI
@onready var dialogue_label: Label = $Tutorial_UI/DialogueContainer/DialoguePanel/MarginContainer/DialogueLabel
@onready var character_portrait: TextureRect = $Tutorial_UI/DialogueContainer/TutorialCatPortrait
@onready var tutorial_character: CharacterBody2D = $EntityManager/TutorialCat
@onready var tutorial_markers: Node = $TutorialMarkers

## Tracks if player has moved during tutorial
var player_has_moved: bool = false
## Tracks if player has interacted during tutorial
var player_has_interacted: bool = false
## Tracks shelf item count for tutorial
var shelf_item_count_before: int = 0

## Size of player's window
var viewport_size: Vector2
## Moves the inventory UI element
var ui_tween: Tween
## Holds inventory UI position state
var shifted_to_top: bool = false
## Holds inventory UI scaling values
var scaled_size: Vector2
## Holds position for inventory UI to default to
var orig_pos: Vector2

func _ready()->void:
	add_to_group("main_shop")
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Tutorial setup
	DialogueManager.dialogue_shown.connect(_on_dialogue_shown)
	print(">>> Signal connected, is_connected:", DialogueManager.dialogue_shown.is_connected(_on_dialogue_shown))
	DialogueManager.tutorial_complete.connect(_on_tutorial_complete)
	tutorial_ui.visible = false
	
	if not GameManager.tutorial_completed:
		await get_tree().process_frame  # Wait for entities to load
		for cauldron: Node2D in get_tree().get_nodes_in_group("tutorial_cauldron"):
			if cauldron.has_node("MixTimer"):
				var timer: Timer = cauldron.get_node("MixTimer")
				timer.timeout.connect(_on_tutorial_cauldron_done)
		print(">>> Starting tutorial, tutorial_completed =", GameManager.tutorial_completed)
		tutorial_ui.visible = true
		DialogueManager.start_tutorial()
	else:
		print(">>> Tutorial already done, skipping")

	
	await get_tree().process_frame
	viewport_size = get_viewport_rect().size
	_on_viewport_size_changed() # initalize inv UI position

func _process(_delta: float) -> void:
	if not GameManager.tutorial_completed:
		var current_step: Dictionary = DialogueManager.tutorial_steps[DialogueManager.current_step_index]
		
		# Check if a NEW potion was stocked
		if current_step["id"] == "stock_shelf":
			var current_count: int = 0
			for shelf: Node2D in get_tree().get_nodes_in_group("tutorial_shelf"):
				if "inv" in shelf and shelf.inv:
					for slot in shelf.inv.slots:
						if slot.item and slot.item.sellable:
							current_count += 1
			
			# If count increased, they stocked something
			if current_count > shelf_item_count_before:
				DialogueManager.advance_tutorial("item_stocked")
				return
		
		# Check if shelf UI was closed
		elif current_step["id"] == "close_shelf":
			var player: Player = $EntityManager/Player
			if player.can_move:
				DialogueManager.advance_tutorial("shelf_closed")
				return
				

		# Check if shelf UI was closed
		elif current_step["id"] == "close_shelf":
			var player: Player = $EntityManager/Player
			if player.can_move:
				DialogueManager.advance_tutorial("shelf_closed")
				return

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneManager.change_to("res://scenes/town/town.tscn")

## Moves the camera when the player transitions from the frontroom to the backroom or the backroom 
## to the frontroom
func transition_camera(top_left: Marker2D, bottom_right: Marker2D) -> void:
	player_camera.limit_left = int(top_left.global_position.x)
	player_camera.limit_top = int(top_left.global_position.y)
	player_camera.limit_right = int(bottom_right.global_position.x)
	player_camera.limit_bottom = int(bottom_right.global_position.y)

func _on_move_storage_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		print(">>> Player entered backroom")
		body.global_position = backroom_frontdoor_dest_marker.global_position
		transition_camera(b_top_left, b_bottom_right)
		
		# Only advance tutorial if it's still active
		if not GameManager.tutorial_completed:
			print(">>> Current tutorial step:", DialogueManager.tutorial_steps[DialogueManager.current_step_index].get("id", "unknown"))
			DialogueManager.advance_tutorial("entered_backroom")
	
func _on_move_front_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = frontroom_backdoor_dest_marker.global_position
		transition_camera(f_top_left, f_bottom_right)
		
		# Only advance tutorial if it's still active
		if not GameManager.tutorial_completed:
			DialogueManager.advance_tutorial("entered_frontroom")
	
func _on_npc_spawner_npc_spawned(npc_instance : Node2D) -> void:
	if floor_map.shelf_targets.is_empty():
		return # no shelves in shop scene => no valid target for npcs
	setup_npc(npc_instance)
	entity_manager.add_child(npc_instance)
	npc_instance.move_to_point()

## Sets the paramaters for the [param npc] from the shop's [member floor_map]
func setup_npc(npc : Node2D) -> void:
	npc.floor_map = floor_map
	npc.shelves = floor_map.shelf_targets.duplicate()
	npc.target = npc.shelves.pop_at(randi_range(0, len(npc.shelves) - 1))
	npc.checkout = floor_map.checkout
	npc.global_position = floor_map.tilemap.map_to_local(floor_map.spawn)

func _on_viewport_size_changed() -> void:
	viewport_size = get_viewport_rect().size
	scaled_size = inv_ui.size * inv_ui.scale
	orig_pos = Vector2(
		(viewport_size.x - scaled_size.x) /2 ,
		viewport_size.y - scaled_size.y - inv_ui.size.y
	)
	
	inv_ui.position = get_target_pos()

## Calculates ideal inventory UI position based on window screen
func get_target_pos() -> Vector2:
	var offset_scale: float = 6
	var target_y: float
	if shifted_to_top:
		target_y = orig_pos.y - (viewport_size.y) + (offset_scale*inv_ui.size.y)
	else:
		target_y = orig_pos.y
	return Vector2(orig_pos.x, target_y)

## Handles dynamic movement of inventory UI when it blocks the player at the bottom of the screen
func shift_ui(to_top: bool) -> void:
	shifted_to_top = to_top
	
	if ui_tween and ui_tween.is_running():
		ui_tween.kill()
	
	ui_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	ui_tween.tween_property(inv_ui, "position", get_target_pos(), 0.3)

func _on_bottom_collision_body_entered_frontroom(body: Node2D) -> void:
	if body is Player:
		shift_ui(true)

func _on_bottom_collision_body_entered_backroom(body: Node2D) -> void:
	if body is Player:
		shift_ui(true)

func _on_bottom_collision_body_exited_frontroom(body: Node2D) -> void:
	if body is Player:
		shift_ui(false)

func _on_bottom_collision_body_exited_backroom(body: Node2D) -> void:
	if body is Player:
		shift_ui(false)
		
func _on_dialogue_shown(text: String) -> void:
	var step: Dictionary = DialogueManager.tutorial_steps[DialogueManager.current_step_index]
	
	if step.has("marker"):
		var marker_name: String = step["marker"]
		var marker: Marker2D = tutorial_markers.get_node_or_null(marker_name)
		if marker:
			print(">>> Moving TutorialCat to:", marker.global_position)
			tutorial_character.global_position = marker.global_position
			tutorial_character.visible = true
		else:
			print(">>> Marker not found:", marker_name)
	
	dialogue_label.text = text

func _on_tutorial_complete() -> void:
	print(">>> TUTORIAL COMPLETE TRIGGERED!")
	tutorial_ui.visible = false
	character_portrait.visible = false
	if is_instance_valid(tutorial_character):
		if tutorial_character.has_node("SpeechBubble"):
			tutorial_character.get_node("SpeechBubble").visible = false
	
func _on_player_moved() -> void:
	if not GameManager.tutorial_completed:
		var current_step: Dictionary = DialogueManager.tutorial_steps[DialogueManager.current_step_index]
		# Only trigger movement for steps that actually wait for it
		if current_step.get("wait_for") == "player_moved":
			DialogueManager.advance_tutorial("player_moved")

func _on_player_interacted() -> void:
	if not player_has_interacted and not GameManager.tutorial_completed:
		player_has_interacted = true
		DialogueManager.advance_tutorial("item_interacted")

func _input(event: InputEvent) -> void:
	if not GameManager.tutorial_completed:
		# Detect movement (no check for player_has_moved)
		if event.is_action_pressed("move_up") or event.is_action_pressed("move_down") or \
		   event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
			_on_player_moved()
		
		# Detect interact with tutorial items
		if not player_has_interacted:
			if event.is_action_pressed("interact"):
				check_tutorial_item_interaction()

func check_tutorial_item_interaction() -> void:
	var player : Player = $EntityManager/Player
	
	# Check for crate (bottle)
	for crate: Node2D in get_tree().get_nodes_in_group("tutorial_crate"):
		if player.global_position.distance_to(crate.global_position) < 50:
			DialogueManager.advance_tutorial("bottle_grabbed")
			return
	
	# Check for barrel (ingredients) - bottle should get filled
	for barrel: Node2D in get_tree().get_nodes_in_group("tutorial_barrel"):
		if player.global_position.distance_to(barrel.global_position) < 50:
			var selected_slot: InvSlot = player.get_selected_slot()
			
			# Accept either empty bottle OR newly filled potion (mixable but not sellable)
			if selected_slot and selected_slot.item:
				var item = selected_slot.item
				if item.texture_code == "item_empty_bottle" or (item.mixable and not item.sellable):
					DialogueManager.advance_tutorial("ingredients_grabbed")
					return
			
			print(">>> You need to select an empty bottle first!")
			return
	
	# Check for cauldron (mixing then grabbing)
	for cauldron: Node2D in get_tree().get_nodes_in_group("tutorial_cauldron"):
		if player.global_position.distance_to(cauldron.global_position) < 50:
			var current_step: Dictionary = DialogueManager.tutorial_steps[DialogueManager.current_step_index]
			
			if current_step["id"] == "mix_potion":
				# Check if cauldron just started mixing (has item and is mixing)
				if cauldron.mixing or (cauldron.inv.slots[0].item and cauldron.inv.slots[0].item.mixable):
					DialogueManager.advance_tutorial("potion_mixed")
					return
				else:
					print(">>> You need a potion with ingredients to mix!")
					return
			elif current_step["id"] == "wait_brewing":
				if not cauldron.mixing:
					DialogueManager.advance_tutorial("potion_ready")
					return
				else:
					print(">>> Potion still brewing, please wait...")
					return
			elif current_step["id"] == "grab_potion":
				# Wait a frame for the interaction to complete
				await get_tree().process_frame
				
				# Check if player now has a sellable potion
				var selected_slot: InvSlot = player.get_selected_slot()
				var has_sellable_potion: bool = (selected_slot and selected_slot.item and selected_slot.item.sellable)
				
				if has_sellable_potion:
					DialogueManager.advance_tutorial("potion_grabbed")
					return
				else:
					print(">>> No finished potion in inventory!")
					return
		
	# Check for shelf (stocking)
	for shelf: Node2D in get_tree().get_nodes_in_group("tutorial_shelf"):
		if player.global_position.distance_to(shelf.global_position) < 50:
			var current_step: Dictionary = DialogueManager.tutorial_steps[DialogueManager.current_step_index]
			
			if current_step["id"] == "go_to_shelf":
				# Count current shelf items before stocking
				shelf_item_count_before = 0
				for shelf_node: Node2D in get_tree().get_nodes_in_group("tutorial_shelf"):
					if "inv" in shelf_node and shelf_node.inv:
						for slot in shelf_node.inv.slots:
							if slot.item and slot.item.sellable:
								shelf_item_count_before += 1
				
				DialogueManager.advance_tutorial("shelf_opened")
				return

func _on_tutorial_item_interacted() -> void:
	if not player_has_interacted and not GameManager.tutorial_completed:
		player_has_interacted = true
		DialogueManager.advance_tutorial("item_interacted")

func _on_tutorial_cauldron_done() -> void:
	var current_step: Dictionary = DialogueManager.tutorial_steps[DialogueManager.current_step_index]
	if current_step["id"] == "wait_brewing":
		DialogueManager.advance_tutorial("potion_ready")
