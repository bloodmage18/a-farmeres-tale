extends Node
## Global run state: day counter, time of day, money and story flags.
## Flags prefixed "daily_" are wiped every time Kojo sleeps.

signal changed

enum TimeOfDay { MORNING, EVENING, NIGHT }

var day := 0
var time := TimeOfDay.EVENING
var money := 0
var flags := {}

# where the next loaded level should place the player (Marker2D name)
var spawn_id := ""
# true while dialogue / fades are running - player and interactables ignore input
var input_locked := false


func has_flag(flag: String) -> bool:
	return flags.get(flag, false)


func set_flag(flag: String, value := true) -> void:
	flags[flag] = value
	changed.emit()


func set_time(new_time: TimeOfDay) -> void:
	time = new_time
	changed.emit()


func add_money(amount: int) -> void:
	money += amount
	changed.emit()


func is_dark() -> bool:
	return time != TimeOfDay.MORNING


func time_name() -> String:
	return ["Morning", "Evening", "Night"][time]


func start_next_day() -> void:
	day += 1
	time = TimeOfDay.MORNING
	for flag in flags.keys():
		if flag.begins_with("daily_"):
			flags.erase(flag)
	changed.emit()


func reset() -> void:
	day = 0
	time = TimeOfDay.EVENING
	money = 0
	flags.clear()
	spawn_id = ""
	input_locked = false
	changed.emit()
