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
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	await get_tree().process_frame
	shifted_to_top = SceneManager.last_known_positions.has("Shop")
	viewport_size = get_viewport_rect().size
	_on_viewport_size_changed() # initalize inv UI position
	if SceneManager.last_known_positions.has("MainShop"):
		shift_ui(true)

func _physics_process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_key_pressed(KEY_HOME):
		floor_map._debug_astar_grid()

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneManager.change_to("res://scenes/town/town.tscn")

func player_sleep() -> void:
	clear_npcs()
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
	var spawner : Node = self.get_node("EntityManager/NpcSpawner")
	spawner._ready()

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

## Moves the camera when the player transitions from the frontroom to the backroom or the backroom 
## to the frontroom
func transition_camera(top_left: Marker2D, bottom_right: Marker2D) -> void:
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
