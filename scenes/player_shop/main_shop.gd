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
## Player
@onready var player : Player = $EntityManager/Player
## Front door spawn marker
@onready var spawn_marker : Marker2D = $FrontRoom/PlayerSpawn
## Tutorial script instance
@onready var tutorial: CanvasLayer = $Tutorial_UI
## Clock
@onready var clock : Control = $Static_UI/Clock
## Tutorial cat
@onready var tutorial_cat : StaticBody2D = $EntityManager/TutorialCat
## Dialogue UI
@onready var dialogue_ui : CanvasLayer = $DialogueUI
## Spawner
@onready var spawner : Node = $EntityManager/NpcSpawner

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
	get_viewport().size_changed.connect(_on_viewport_size_changed)

	await get_tree().process_frame # wait for all entities to load in
	if not GameManager.tutorial_completed:
		tutorial.setup(self)
		tutorial.tutorial_complete.connect(_on_tutorial_complete)
		tutorial.start(DialogueManager.get_array("tutorial", "tutorial"))
		clock.visible = false
		spawner.npc_respawn_timer.stop()
	else:
		tutorial.visible = false
		clock.visible = true
		TimeManager.set_process(true)
		if tutorial_cat.has_node("SpeechBubble"):
			tutorial_cat.get_node("SpeechBubble").visible = false
	
	viewport_size = get_viewport_rect().size
	check_camera_pos()
	_on_viewport_size_changed() # initalize inv UI position
	dialogue_ui.action_triggered.connect(_on_dialogue_action)

func check_camera_pos() -> void:
	if player.global_position.y <= b_bottom_right.global_position.y:
		transition_camera(b_top_left, b_bottom_right)
	else:
		transition_camera(f_top_left, f_bottom_right)
	player_camera.reset_smoothing()

func _physics_process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_key_pressed(KEY_HOME):
		floor_map._debug_astar_grid()

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		if not GameManager.tutorial_completed:
			skip_tutorial()
		else:
			var payload : Dictionary = SceneManager.get_payload()
			payload["player_position"] = spawn_marker.global_position
			SceneManager.change_to("res://scenes/town/town.tscn", payload)

func player_sleep() -> void:
	GameManager.player_passed_out = false
	clear_npcs()
	close_open_shelf()
	var fade : TextureRect = self.get_node("SleepFade")
	fade.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1, 0.5).from(0.0)
	TimeManager.set_process(false)
	tween.tween_property(fade, "modulate:a", 0.0, 0.5)
	TimeManager.time = 0
	TimeManager.day += 1
	await tween.finished
	fade.visible = false
	TimeManager.set_process(true)
	TimeManager.time = 0.0
	spawner._ready()

func close_open_shelf() -> void:
	var em : EntityManager = get_node("EntityManager")
	for child in em.get_children():
		if child is Shelf and child.shelf_ui.visible:
			child.close_shelf()

func clear_npcs() -> void:
	var em : EntityManager = get_node("EntityManager")
	var return_basket : ReturnBasket = get_node("EntityManager/ReturnBasket")
	var register : Node2D = get_node("EntityManager/CashRegister")
	for child in em.get_children():
		if child is ShopNpc:
			if child.item_found:
				var potion : InvItem = ItemRegistry.new_item(child.prefered_item)
				potion.mixable = false
				potion.sellable = true
				return_basket.return_item(potion)
			child.free()
	register.cust_waiting_icon.visible = false

## Moves the camera when the player transitions from the frontroom to the backroom or vice versa
func transition_camera(top_left: Marker2D, bottom_right: Marker2D) -> void:
	await get_tree().process_frame
	player_camera.limit_left = int(top_left.global_position.x)
	player_camera.limit_top = int(top_left.global_position.y)
	player_camera.limit_right = int(bottom_right.global_position.x)
	player_camera.limit_bottom = int(bottom_right.global_position.y)

func _on_move_storage_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = backroom_frontdoor_dest_marker.global_position
		transition_camera(b_top_left, b_bottom_right)

func _on_move_front_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = frontroom_backdoor_dest_marker.global_position
		transition_camera(f_top_left, f_bottom_right)

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
	npc.checkout = floor_map.checkout
	npc.global_position = floor_map.tilemap.map_to_local(floor_map.spawn)
	npc.return_basket = floor_map.return_basket

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
		await get_tree().process_frame
		shift_ui(true)

func _on_bottom_collision_body_entered_backroom(body: Node2D) -> void:
	if body is Player:
		await get_tree().process_frame
		shift_ui(true)

func _on_bottom_collision_body_exited_frontroom(body: Node2D) -> void:
	if body is Player:
		await get_tree().process_frame
		shift_ui(false)

func _on_bottom_collision_body_exited_backroom(body: Node2D) -> void:
	if body is Player:
		await get_tree().process_frame
		shift_ui(false)

func _on_tutorial_complete() -> void:
	if tutorial:
		tutorial.on_complete()
		clock.visible = true
	tutorial = null
	GameManager.tutorial_completed = true
	TimeManager.set_process(true)
	spawner.npc_respawn_timer.start()

func _on_dialogue_action(action: String, _data: Dictionary) -> void:
	if action == "skip_tutorial":
		dialogue_ui.close()
		_on_tutorial_complete()
		var payload : Dictionary = SceneManager.get_payload()
		payload["player_position"] = spawn_marker.global_position
		SceneManager.change_to("res://scenes/town/town.tscn", payload)
	elif action == "continue_tutorial":
		dialogue_ui.close()
		TimeManager.set_process(false)
		if tutorial:
			tutorial.visible = true
		inv_ui.visible = true

func skip_tutorial() -> void:
	tutorial.visible = false
	inv_ui.visible = false
	dialogue_ui.open("tutorial", "skip_tutorial")
