extends CharacterBody2D
@onready var sprite : = $AnimatedSprite2D

const TYPES : Array = [Color(1,0.5,0.5,1), Color(0.5,1,0.5,1), Color(0.5,0.5,1,1), Color(0.2,0.2,0.2,1)]
var astar : AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:
	var color : int = randi_range(0,TYPES.size() - 1)
	sprite.modulate = TYPES[color]
