extends Entity

@onready var light: PointLight2D = $PointLight2D
var glow_time: float = 0.0
var base_energy: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_code = "customer-lantern"
	
	light.visible = false
	
	


func start_glow() -> void:
	light.visible = true

func stop_glow() -> void:
	light.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	glow_time += delta
	light.energy = base_energy + sin(glow_time * 1.5)
