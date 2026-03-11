extends Node2D

@onready var wheel: Sprite2D = $Wheel
@onready var is_spinning : bool = false
@onready var can_spin : bool = true
var speed : float
var power : float
@onready var interactable : Node = $Interactable
@onready var entity: Sprite2D = $Wheel/Entity
@onready var marker: Marker2D = $Marker/Marker2D
@onready var progress_bar: ProgressBar = $ProgressBar

signal wheel_spin
signal give_prize

var prizes : Dictionary = {
	"Prize1": {
		"type": "chips",
		"value": 20
	},
	"Prize2": {
		"type": "entity",
		"value": 1
	},
	"Prize3": {
		"type": "coins",
		"value": 100
	},
	"Prize4": {
		"type": "chips",
		"value": 50
	},
	"Prize5": {
		"type": "coins",
		"value": 20
	},
	"Prize6": {
		"type": "None",
		"value": 0
	},
	"Prize7": {
		"type": "chips",
		"value": 100
	},
	"Prize8": {
		"type": "coins",
		"value": 50
	}
}

func _ready() -> void:
	var rand_rot : float = randf_range(0, 3)
	wheel.rotate(rand_rot)
	interactable.interact = _on_interact
	wheel_spin.connect(TimeManager._on_prize_wheel_spin)
	give_prize.connect(_on_give_prize)

func _physics_process(delta: float) -> void:
	if is_spinning:
		if can_spin and Input.is_action_pressed("interact"):
			power += delta * 5
			progress_bar.value = min((power / 30) * 100, 100)
			speed = max(min(power, 30), 11)
		elif speed > 0:
			progress_bar.visible = false
			can_spin = false
			wheel.rotate(speed * delta)
			speed -= delta
		else:
			can_spin = true
			is_spinning = false
			give_prize.emit()

func _on_interact() -> void:
	# if wheel has already been spun today don't spin again
	if is_spinning or TimeManager.last_wheel_spin == TimeManager.day:
		return
	is_spinning = true
	progress_bar.visible = true
	wheel_spin.emit()

func _on_give_prize() -> void:
	var distances : Dictionary = {}
	var player : Player = get_tree().get_first_node_in_group("player")
	var win : String
	for child in get_node("Wheel/PrizeMarkers").get_children():
		distances[child.name] = calc_dist(marker.global_position, child.global_position)
	win = distances.find_key(distances.values().min())
	match prizes[win]["type"]:
		"chips":
			player.set_chips(prizes[win]["value"])
		"coins":
			player.set_coins(prizes[win]["value"])
		"entity":
			player.set_credit("barrel", 1)
		_:
			pass

func calc_dist(p1: Vector2, p2: Vector2) -> float:
	return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
