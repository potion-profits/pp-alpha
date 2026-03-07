extends Npc

@onready var idle_sheet : Resource = preload(
	"res://assets/char_sprites/npc_sprites/npc_customers/rogue_npc_idle.png"
	)
@onready var interactable: Area2D = $Interactable
@export var is_interactable: bool = true

var interact_key: String = InputMap.get_action_description("interact").split(" ")[0]
var CASINO_CASHIER_TOOLTIP: String = "Press %s to Exchange Shit" %[interact_key]
var SUPPLYSHOP_CASHIER_TOOLTIP: String = "Press %s to Buy Shit" %[interact_key]

func _ready() -> void:
	sprite.sprite_frames = build_sprite_frames(idle_sheet, null)
	sprite.play("idle_down")
	sprite.frame = randi_range(0, 3)
	interactable.is_interactable = is_interactable
	
	# Change tooltip depending on scene the NPC is in
	var current_scene : Node = SceneManager.current_scene()	
	if (current_scene.name == "CasinoFloor"):
		interactable.tooltip = CASINO_CASHIER_TOOLTIP
	elif (current_scene.name == "SupplyShop"):
		interactable.tooltip = SUPPLYSHOP_CASHIER_TOOLTIP
