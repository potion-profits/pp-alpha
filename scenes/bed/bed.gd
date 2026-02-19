extends Entity

## The bed is an interactable entity that saves the game.

@onready var interactable : Area2D = $Interactable ## Reference to component used for interactions
@onready var bed_sfx : AudioStreamPlayer2D = $BedSFX ## Reference to audio stream 
const SAVE_PROMPT = "Press E to save the game"
const SAVE_OK = "Game saved successfully"

var timed_out: bool = false

func _ready() -> void:
	# Links interactable template to bed specific method
	interactable.interact = _on_interact
	interactable.tooltip = SAVE_PROMPT
	# Sets up entity info
	super._ready()
	
	# Used to find out what scene to place in entity manager
	entity_code = "bed"

func _on_interact() -> void:
	if timed_out:
		return
	GameManager.save_scene_runtime_state()
	GameManager.commit_to_storage()
	TimeManager.player_sleep()
	_save_timeout()
	bed_sfx.play()

func _save_timeout() -> void:
	interactable.tooltip = SAVE_OK
	timed_out = true
	var t: SceneTreeTimer = get_tree().create_timer(2)
	await t.timeout
	interactable.tooltip = SAVE_PROMPT
	timed_out = false
