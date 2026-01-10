extends Entity

## Handles the lighting aspect of the lantern.
##
## @experimental: Currently unused but will likely be added as a possible shop upgrade.

@onready var light: PointLight2D = $PointLight2D	## Reference to lighting
var glow_time: float = 0.0	## Modulates based on frame processing
var base_energy: float = 1.0	## Dictates lighting energy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_code = "customer-lantern"
	
	light.visible = false

## Starts the lighting aspect
func start_glow() -> void:
	light.visible = true

## Stops the lighting aspect
func stop_glow() -> void:
	light.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	glow_time += delta
	light.energy = base_energy + sin(glow_time * 1.5)
