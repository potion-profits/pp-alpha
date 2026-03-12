extends Npc

@onready var idle_sheet : Resource = preload(
	"res://assets/char_sprites/npc_sprites/npc_customers/rogue_npc_idle.png"
	)
@onready var interactable: Area2D = $Interactable
@export var is_interactable: bool = true

var player_in_area: Player
var CASINO_CASHIER_TOOLTIP: String = "Press %s to Exchange Shit"
var SUPPLYSHOP_CASHIER_TOOLTIP: String = "Press %s to Buy Shit"

func _ready() -> void:
	sprite.sprite_frames = build_sprite_frames(idle_sheet, null)
	sprite.play("idle_down")
	sprite.frame = randi_range(0, 3)
	interactable.is_interactable = is_interactable
	
	# Change tooltip depending on scene the NPC is in
	var current_scene : Node = SceneManager.current_scene()	
	if (current_scene.name == "CasinoFloor"):
		interactable.set_tooltip_label(CASINO_CASHIER_TOOLTIP)
	elif (current_scene.name == "SupplyShop"):
		interactable.set_tooltip_label(SUPPLYSHOP_CASHIER_TOOLTIP)


func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = body
		set_process(true)

func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = null
		set_process(false)
		
func _process(_delta: float) -> void:
	if player_in_area:
		var current_scene : Node = SceneManager.current_scene()
		
		if (current_scene.name == "CasinoFloor"):
			interactable.set_tooltip_label(CASINO_CASHIER_TOOLTIP)
		elif (current_scene.name == "SupplyShop"):
			interactable.set_tooltip_label(SUPPLYSHOP_CASHIER_TOOLTIP)
