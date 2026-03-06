class_name Elevator extends StaticBody2D

@onready var collision: CollisionShape2D = $ClosedCollision
@onready var floors: Sprite2D = $Floors
@onready var buttons: Sprite2D = $Buttons
@onready var doors: AnimatedSprite2D = $ElevatorDoors
@onready var interactable: Area2D = $Interactable
@onready var dialogue_ui: CanvasLayer = $DialogueUI

func _ready() -> void:
	doors.frame = 0
	
func _on_dialogue_action()->void:
	doors.play("default")


func _on_elevator_doors_animation_finished() -> void:
	collision.disabled = true
	
