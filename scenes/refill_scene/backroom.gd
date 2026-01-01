extends Node2D

@onready var em: EntityManager = $EntityManager
@onready var player: Player = $EntityManager/Player
@onready var static_ui: CanvasLayer = $Static_UI

var target: String
var cost: int
var type: String

enum Direction{
	NONE,
	LEFT,
	RIGHT,
	UP,
	DOWN
}

var selectables: Array = []
var idx: int = 0

var first_delay: float = 0.3
var repeat_delay: float = 0.1
var hold_time: float = 0.0

var repeat : bool = false
var holding_dir : Direction = Direction.NONE

func _ready()->void:
	player.set_physics_process(false)
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	await get_tree().process_frame
	
	var payload : Dictionary = SceneManager.get_payload()
	target = payload.get("target", "barrel")
	cost = payload.get("cost", null)
	type = payload.get("type", "red_barrel")
	
	if em:
		for child in em.get_children():
			if child is Entity and child.entity_code == target:
				selectables.append(child)
	
	if not selectables.is_empty():
		selectables[idx].highlight()

func refill()->void:
	if player.get_coins() >= cost:
		player.set_coins(-cost)
		selectables[idx].refill(type)
	if player.get_coins() < cost:
		print("ran out of money")
		await get_tree().process_frame
		menu()

func move_right()->void:
	selectables[idx].un_highlight()
	idx = (idx+1)%selectables.size()
	selectables[idx].highlight()

func move_left()->void:
	selectables[idx].un_highlight()
	idx = (idx-1)%selectables.size()
	selectables[idx].highlight()

func _start_hold(dir: Direction) -> void:
	holding_dir = dir
	hold_time = 0.0
	repeat = false
	_step()
	
func _stop_hold()->void:
	holding_dir = Direction.NONE
	
func _step() -> void:
	match holding_dir:
		Direction.LEFT:
			move_left()
		Direction.RIGHT:
			move_right()
		Direction.UP:
			pass
		Direction.DOWN:
			pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		_start_hold(Direction.LEFT)
		
	if event.is_action_pressed("move_right"):
		_start_hold(Direction.RIGHT)
	
	if event.is_action_released("move_left") and holding_dir == Direction.LEFT:
		_stop_hold()
	
	if event.is_action_released("move_right") and holding_dir == Direction.RIGHT:
		_stop_hold()
	
	if event.is_action_pressed("interact"):
		_stop_hold()
		refill()

func _process(delta: float) -> void:
	if holding_dir == Direction.NONE:
		return
	
	hold_time += delta
	
	if not repeat:
		if hold_time >= first_delay:
			repeat = true
			hold_time = 0.0
	else:
		if hold_time >= repeat_delay:
			hold_time = 0.0
			_step()

func menu()->void:
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")
