extends Entity

## The bed is an interactable entity that saves the game.

@onready var interactable : Area2D = $Interactable ## Reference to component used for interactions
@onready var bed_sfx : AudioStreamPlayer2D = $BedSFX ## Reference to audio stream

var player_in_area: Player
var SAVE_PROMPT: String = "Press %s to save the game"
const SAVE_OK = "Game saved successfully"

var timed_out: bool = false

func _ready() -> void:
	# Links interactable template to bed specific method
	interactable.interact = _on_interact
	interactable.is_interactable = false
	
	# Sets up entity info
	super._ready()
	
	# Used to find out what scene to place in entity manager
	entity_code = "bed"

func _on_interact() -> void:
	if timed_out:
		return
	player_sleep()
	GameManager.save_scene_runtime_state()
	GameManager.commit_to_storage()
	_save_timeout()
	bed_sfx.play()

func _save_timeout() -> void:
	interactable.tooltip = SAVE_OK
	timed_out = true
	var t: SceneTreeTimer = get_tree().create_timer(2)
	await t.timeout
	interactable.tooltip = SAVE_PROMPT
	timed_out = false


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
		interactable.set_tooltip_label(SAVE_PROMPT)
		interactable.is_interactable = true
	else:
		interactable.is_interactable = false

func player_sleep() -> void:
	var cs : Node = SceneManager.current_scene()
	GameManager.player_passed_out = false
	cs.clear_npcs()
	close_open_shelf(cs)
	var fade : TextureRect = cs.get_node("SleepFade")
	fade.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1, 0.5).from(0.0)
	TimeManager.set_process(false)
	tween.tween_property(fade, "modulate:a", 0.0, 0.5)
	TimeManager.time = 0
	TimeManager.day += 1
	await tween.finished
	fade.visible = false
	TimeManager.set_process(true)
	TimeManager.time = 0.0
	cs.spawner._ready()

func close_open_shelf(shop: Node) -> void:
	var em : EntityManager = shop.get_node("EntityManager")
	for child in em.get_children():
		if child is Shelf and child.shelf_ui.visible:
			child.close_shelf()
