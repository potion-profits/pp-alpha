extends GutTest

func test_get_str_from_time() -> void:
	TimeManager.time = 3678
	var res : String = TimeManager.get_string_from_time()
	assert_eq(res, "08:01", "After 3678 s, time should be '8:01'")
	TimeManager.time = 22240
	res = TimeManager.get_string_from_time()
	assert_eq(res, "13:10", "After 216640 s, time should be '13:10'")
	TimeManager.time = 44640
	res = TimeManager.get_string_from_time()
	assert_eq(res, "18:12", 
		"After 36000 s, time is twice as slow, the remaining time is 1 hr 2 mins resulting in '18:02'")
	TimeManager.time = 36000
	res = TimeManager.get_string_from_time()
	assert_eq(res, "17:00", "After 3600 s, time should be '17:00' exactly")
	TimeManager.time = (86400)
	res = TimeManager.get_string_from_time()
	assert_eq(res, "00:00", "After 54000 s, time should be '00:00' exactly")

func test_get_time_from_str() -> void:
	var res : int = TimeManager.get_time_from_string('00:00')
	assert_eq(res, 86400, "'00:00' is equivalent to 54,000 s in-game")
	res = TimeManager.get_time_from_string('17:00')
	assert_eq(res, 36000, "'17:00' is equivalent to 36000 s in-game")
	res = TimeManager.get_time_from_string('08:00')
	assert_eq(res, 3600, "'08:00' is equivalent to 3600 s in-game")
	
