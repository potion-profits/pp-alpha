extends Node

class_name DirectionalHoldController

# delays for moving through selections
var first_delay: float = 0.3	## Threshold to start moving after initially holding.
var repeat_delay: float = 0.1	## Threshold to continue moving while holding.

# holding state
var repeat : bool = false ## Flag for handling moving while holding
var hold_time: float = 0.0	## Time [member holding_dir] has been held since last move.
var holding_dir : Direction = Direction.NONE ## Tells what direction is being held.

## All possible directions the selection can move & none for when it should not move.
enum Direction{
	NONE,
	LEFT,
	RIGHT,
	UP,		# not used yet but will likely be useful when on grid
	DOWN	# not used yet but will likely be useful when on grid
}

signal stepped(dir:Direction)

## Turns on the holding mechanism for smoother selection
func start_hold(dir: Direction) -> void:
	holding_dir = dir
	hold_time = 0.0
	repeat = false
	stepped.emit(holding_dir)
	
## Turns off the holding mechanism for smoother selection
func stop_hold()->void:
	holding_dir = Direction.NONE

func process(delta:float)->void:
	if holding_dir == Direction.NONE:
		return
	
	hold_time += delta
	
	if not repeat:
		if hold_time >= first_delay:
			repeat = true
			hold_time = 0.0
	else:
		if hold_time >= repeat_delay:
			hold_time = 0.0
			stepped.emit(holding_dir)
