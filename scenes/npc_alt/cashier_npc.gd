extends Npc

@onready var idle_sheet : Resource = preload(
	"res://assets/char_sprites/npc_sprites/npc_customers/rogue_npc_idle.png"
	)
@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	sprite.sprite_frames = build_sprite_frames(idle_sheet, null)
	sprite.play("idle_down")
