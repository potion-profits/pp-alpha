extends Node

## Reference to [Npc] scene
var npc_scene : PackedScene = preload("res://scenes/npc_alt/basic_npc.tscn")
## Controls time before new NPC respawns
@onready var npc_respawn_timer : Timer = $NPCRespawnTimer
## Stores randf time to set [member npc_respawn_timer] to
var time : float
signal npc_spawned	## Sent to shop to handle NPC instance setup

const init_min = 7.0
const init_max = 15.0
const cont_min = 3.0
const cont_max = 8.0

## Idle/Walk directions in row order of sprite sheets
const directions : Array = ["down", "downleft", "left", "upleft", "up"]
## Frame size, dictated by idle/walk cycle sprite sheet
const frame_size_idle : Vector2 = Vector2(16, 16)
const frame_size_walk : Vector2 = Vector2(20, 19)
## Animation constants
const frames_per_anim : int = 4
const fps : float = 5.0

## Holds variants of customerse, specifically their sprite sheets and potion preference
var customer_variants : Array = [
	{
		"idle": preload("res://assets/char_sprites/npc_sprites/npc_customers/fighter_npc_idle.png"),
		"walk": preload("res://assets/char_sprites/npc_sprites/npc_customers/fighter_npc_walk_cycle.png"),
		"preferred_item": "item_red_potion"
	},
	{
		"idle": preload("res://assets/char_sprites/npc_sprites/npc_customers/druid_npc_idle.png"),
		"walk": preload("res://assets/char_sprites/npc_sprites/npc_customers/druid_npc_walk_cycle.png"),
		"preferred_item": "item_green_potion"
	},
	{
		"idle": preload("res://assets/char_sprites/npc_sprites/npc_customers/mage_npc_idle.png"),
		"walk": preload("res://assets/char_sprites/npc_sprites/npc_customers/mage_npc_walk_cycle.png"),
		"preferred_item": "item_blue_potion"
	},
	{
		"idle": preload("res://assets/char_sprites/npc_sprites/npc_customers/rogue_npc_idle.png"),
		"walk": preload("res://assets/char_sprites/npc_sprites/npc_customers/rogue_npc_walk_cycle.png"),
		"preferred_item": "item_dark_potion"
	},
]

func _ready() -> void:
	time = randf_range(init_min, init_max)
	npc_respawn_timer.start(time)

func _on_npc_respawn_timer_timeout() -> void:
	var npc_instance : CharacterBody2D = npc_scene.instantiate()
	
	var variant : Dictionary = customer_variants.pick_random()
	npc_instance.get_node("AnimatedSprite2D").sprite_frames = build_sprite_frames(variant["idle"], variant["walk"])
	npc_instance.prefered_item = variant["preferred_item"]
	
	npc_spawned.emit(npc_instance)
	time = randf_range(cont_min, cont_max)
	npc_respawn_timer.start(time)

## Builds the sprite frames animations for the different customer variants
## Default variant is the fighter_npc that prefers red potions
func build_sprite_frames(idle_sheet: Texture2D, walk_sheet: Texture2D) -> SpriteFrames:
	var sf : SpriteFrames = SpriteFrames.new()
	sf.remove_animation("default")

	for row in range(directions.size()):
		var dir : String = directions[row]
		 
		sf.add_animation("idle_" + dir)
		sf.set_animation_speed("idle_" + dir, fps)
		sf.set_animation_loop("idle_" + dir, true)
		for col in range(frames_per_anim):
			var atlas : AtlasTexture = AtlasTexture.new()
			atlas.atlas = idle_sheet
			atlas.region = Rect2(col * frame_size_idle.x, row * frame_size_idle.y, frame_size_idle.x, frame_size_idle.y)
			sf.add_frame("idle_" + dir, atlas)
		
		sf.add_animation("walking_" + dir)
		sf.set_animation_speed("walking_" + dir, fps)
		sf.set_animation_loop("walking_" + dir, true)
		for col in range(frames_per_anim):
			var atlas : AtlasTexture = AtlasTexture.new()
			atlas.atlas = walk_sheet
			atlas.region = Rect2(col * frame_size_walk.x, row * frame_size_walk.y, frame_size_walk.x, frame_size_walk.y)
			sf.add_frame("walking_" + dir, atlas)

	return sf
