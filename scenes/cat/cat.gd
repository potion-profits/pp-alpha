# tutorial_cat.gd
extends StaticBody2D

@onready var body_sprite: Sprite2D = $Body
@onready var eyes_sprite: AnimatedSprite2D = $Eyes
@onready var tail_sprite: AnimatedSprite2D = $Tail

var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
	
	update_eyes()

func update_eyes() -> void:
	var dir: Vector2 = player.global_position - global_position
	
	# 4 frames: 0=top-right, 1=bottom-right, 2=bottom-left, 3=top-left
	if dir.x >= 0 and dir.y <= 0:
		eyes_sprite.frame = 0  # top-right
	elif dir.x >= 0 and dir.y > 0:
		eyes_sprite.frame = 1  # bottom-right
	elif dir.x < 0 and dir.y > 0:
		eyes_sprite.frame = 2  # bottom-left
	else:
		eyes_sprite.frame = 3  # top-left
