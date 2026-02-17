class_name KeybindContainer
extends Resource

# match to project input map
const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const MOVE_UP : String = "move_up"
const MOVE_DOWN : String = "move_down"
const INTERACT : String = "interact"
const DASH : String = "sprint"
const SLOT_1 : String = "slot_1"
const SLOT_2 : String = "slot_2"
const SLOT_3 : String = "slot_3"
const SLOT_4 : String = "slot_4"
const SLOT_5 : String = "slot_5"

# Export to resource all default values (default values determined by project input map)
@export var DEFAULT_MOVE_LEFT_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_MOVE_UP_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_MOVE_DOWN_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_INTERACT_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_DASH_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_SLOT_1_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_SLOT_2_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_SLOT_3_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_SLOT_4_KEY : InputEventKey = InputEventKey.new()
@export var DEFAULT_SLOT_5_KEY : InputEventKey = InputEventKey.new()

# Player defined input values if default not used
var move_left_key : InputEventKey = InputEventKey.new()
var move_right_key : InputEventKey = InputEventKey.new()
var move_up_key : InputEventKey = InputEventKey.new()
var move_down_key : InputEventKey = InputEventKey.new()
var interact_key : InputEventKey = InputEventKey.new()
var dash_key : InputEventKey = InputEventKey.new()
var slot_1_key : InputEventKey = InputEventKey.new()
var slot_2_key : InputEventKey = InputEventKey.new()
var slot_3_key : InputEventKey = InputEventKey.new()
var slot_4_key : InputEventKey = InputEventKey.new()
var slot_5_key : InputEventKey = InputEventKey.new()
