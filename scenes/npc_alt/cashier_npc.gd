extends Npc

@onready var idle_sheet : Resource = preload(
	"res://assets/char_sprites/npc_sprites/npc_customers/rogue_npc_idle.png"
	)
@onready var interactable: Area2D = $Interactable
@export var is_interactable: bool = true

func _ready() -> void:
	sprite.sprite_frames = build_sprite_frames(idle_sheet, null)
	sprite.play("idle_down")
	sprite.frame = randi_range(0, 3)
	interactable.is_interactable = is_interactable
	
	interactable.tooltip = ""
