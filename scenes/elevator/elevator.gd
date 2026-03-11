class_name Elevator extends StaticBody2D

@onready var collision: CollisionShape2D = $ClosedCollision
@onready var floors: AnimatedSprite2D = $Floors
@onready var buttons: Sprite2D = $Buttons
@onready var doors: AnimatedSprite2D = $ElevatorDoors
@onready var interactable: Area2D = $Interactable
@onready var button_up: Sprite2D = $ButtonUp
@onready var button_down: Sprite2D = $ButtonDown

const floor_nums = 8
const region : Vector2 = Vector2(32,16)

var start_floor : int = 0

const SHEET_PATH = "res://assets/interior/casino/elevator.png"

func set_floor(new_floor: int)->void:
	start_floor = new_floor
	floors.frame = 0

func _on_elevator_doors_animation_finished() -> void:
	collision.disabled = true
	var pload : Dictionary
	if start_floor == 0:
		pload = {"destination": "res://scenes/penthouse/penthouse.tscn"}
	else:
		pload = {"destination": "res://scenes/casino/casino_floor.tscn"}
	SceneManager.change_to("res://scenes/elevator/inside.tscn", pload)

func start_anim() -> void:
	if start_floor == 0:
		show_button_up()
		floors.play_backwards()
	else:
		show_button_down()
		floors.play()

func show_button_up() -> void:
	buttons.hide()
	button_down.hide()
	button_up.show()

func show_button_down() -> void:
	buttons.hide()
	button_down.show()
	button_up.hide()

func show_buttons() -> void:
	buttons.show()
	button_down.hide()
	button_up.hide()

func _on_floors_animation_finished() -> void:
	show_buttons()
	doors.play()
	
