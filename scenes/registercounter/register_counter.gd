extends Entity

"""
Register and counter

"""

@onready var customer_detect_area: Area2D = $CustomerDetection
@onready var customer_detect_icon: Sprite2D = $CustomerWaitingIcon

@export var lantern: Node2D

var customers_in_area: int = 0
var icon_base_position: Vector2
var bob_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_code = "cauldron"
	
	# default state of customer_detect_icon
	customer_detect_icon.visible = false
	icon_base_position = customer_detect_icon.position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if customer_detect_icon.visible:
		bob_time += delta
		customer_detect_icon.position.y = icon_base_position.y + sin(bob_time * 3.0)

func _on_customer_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body is not Player:
		customers_in_area += 1
		customer_detect_icon.visible = true
		lantern.start_glow()


func _on_customer_detection_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body is not Player:
		customers_in_area -= 1
	if customers_in_area <= 0:
		customer_detect_icon.visible = false
		lantern.stop_glow()
