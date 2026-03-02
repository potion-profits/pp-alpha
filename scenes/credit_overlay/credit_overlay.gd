extends Control

## Handles displaying the player's coins

@export var player: Player	## Will hold a reference to the player once the scene tree is built
@onready var shelf_amt: Label = $Shelf/ShelfAmt
@onready var crate_amt: Label = $Crate/CrateAmt
@onready var barrel_amt: Label = $Barrel/BarrelAmt
@onready var cauldron_amt: Label = $Cauldron/CauldronAmt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_all_credits.call_deferred()
	player.update_credits.connect(update_all_credits)
	
## Visually displays the player's current coins
func update_all_credits() -> void:
	var creds : Dictionary = player.credits
	shelf_amt.text = str(int(creds["shelf"]))
	crate_amt.text = str(int(creds["crate"]))
	barrel_amt.text = str(int(creds["barrel"]))
	cauldron_amt.text = str(int(creds["cauldron"]))
