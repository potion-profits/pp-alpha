extends Node

## Keeps track of time accros all scenes while the game is running
##
## Time is tracked on a 30 hour interval where the player wakes up at "7:00am", has one hour of
## prep (shop opens at 8:00am), customers may visit the shop until "5:00pm" (up to 9 hours of 
## operation), and then the player may do any upkeep (refills, purchases, prep for next day) and
## gamble at the casino for up to the remaining 20 hours in the in-game time cycle. This means that
## the player will have twice as long to spend doing night time activities as they would operating
## the shop[br]
## At any time the player may sleep in the shop bed to advance the in-game day to the next day. [br]
## Each real-world second is multiplied by [constant TIME_FACTOR] to obtain the in-game time.

#const TIME_FACTOR = 120	# each real-world minute is an in-game hour
const TIME_FACTOR = 3600 # for testing make it 60 times faster

const HOUR = 3600
const MIN = 60

## Represents in-game time in seconds
var time : float = 0.0
## Represents days since the game started
var day : int = 0

signal day_end

# don't process until the game is running
# set_process(true) occurs in start_menu.gd when play is pressed
func _ready() -> void:
	TimeManager.set_process(false)
	SceneManager.scene_ready.connect(_on_scene_ready)

func _process(delta: float) -> void:
	time += delta * TIME_FACTOR
	if time >= HOUR * 30:
		# If player doesn't sleep, trigger the pass out feature
		set_process(false)
		var cs : Node = SceneManager.current_scene()
		GameManager.player_passed_out = true
		if cs.name == "MainShop":
			_on_scene_ready()
		else:
			day_end.emit()

## Returns the format string for the in-game time represented as real-world time
func get_string_from_time() -> String:
	@warning_ignore_start("integer_division")
	var time_str : String = "{hr}:{min}"
	var time_as_int : int = int(time)
	var hours : int
	var mins : int
	# if more than 10 hours have passed -> time is twice as slow to allow gambling
	if time_as_int >= HOUR * 10:
		time_as_int -= HOUR * 10
		hours = time_as_int / (HOUR * 2)
		time_as_int -= (HOUR * 2) * hours
		mins = time_as_int / (MIN * 2)
		# slow time starts at 17:00 every evening
		# mod to keep 2400 hour clock time
		hours = (hours + 17) % 24
	else:
		# calc hours
		hours = time_as_int / HOUR
		# subtract hours to get mins
		time_as_int -= HOUR * hours
		# calc mins
		mins = time_as_int / MIN
		# time starts at 07:00 every morning
		hours += 7
	# create time_str (day starts at 7am, add 7 to hours)
	time_str = time_str.format({"hr": str(hours).lpad(2, "0"), "min": str(mins).lpad(2, "0")})
	@warning_ignore_restore("integer_division")
	return time_str

## Returns the in-game time associated with a real-world clock time [br]
## Ex: Passing [code]08:00[/code] returns [code]3600[/code]
func get_time_from_string(s : String) -> int:
	var ret : int = 0
	var split : Array = s.split(":",2)
	var hours : int = int(split[0])
	var mins : int = int(split[1])
	if hours < 7 or hours >= 17:
		if hours < 7:
			hours += 24
		ret += HOUR * 10
		hours -= 17
		ret += hours * (HOUR * 2)
		ret += mins * (MIN * 2)
	else:
		hours -= 7
		ret += hours * HOUR
		ret += mins * MIN
	return ret

func _on_scene_ready() -> void:
	if GameManager.player_passed_out:
		print("player pased out and is being forced to sleep")
		var cs : Node = SceneManager.current_scene()
		await get_tree().process_frame
		if cs.name == "MainShop":
			var player : Player = cs.get_node("EntityManager/Player")
			var bed : Entity = cs.get_node("EntityManager/Bed")
			player.position = bed.position + Vector2(-10, 0)
			cs.player_sleep()
