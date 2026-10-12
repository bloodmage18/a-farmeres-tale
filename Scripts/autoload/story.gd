extends Node
## Every story beat lives here: who is present, what they say, what changes
## afterwards, and what the current objective is. Levels and components only
## ask this script questions - they don't hold story logic themselves.
##
## Arrival (day 0, evening):
##   bus stop -> greet the Chief -> Grandma's house (she's asleep, the young
##   woman tells Kojo to come back tomorrow) -> explore -> sleep in Kojo's room
## Daily loop (day 1+, morning):
##   Grandma gives the day's word + tasks -> tend the farm + herd the cattle
##   -> evening falls -> the young woman is back at the house -> sleep -> repeat

const LEVELS := {
	"bus_stop": "res://Scenes/Levels/bus_stop.tscn",
	"village": "res://Scenes/Levels/village.tscn",
	"chief_palace": "res://Scenes/Levels/chief_palace.tscn",
	"grandma_house": "res://Scenes/Levels/grandma_house.tscn",
	"kojo_room": "res://Scenes/Levels/kojo_room.tscn",
	"farm": "res://Scenes/Levels/farm.tscn",
	"ranch": "res://Scenes/Levels/ranch.tscn",
}

const KOJO := "Kojo"
const GRANDMA := "Grandma Agya"
const CHIEF := "Nana Chief"
const WOMAN := "Young Woman"

const TASK_PAY := 20

# grandma's daily word - a rule or a warning, picked by day number
const GRANDMA_RULES := [
	"Count the cattle before you leave the ranch. Every one of them, every time.",
	"Water the crops before the sun is high, not after.",
	"If the cattle are restless, something is out there. Bring them in early.",
	"Do not go into the forest after dark. Whatever you hear, do not answer.",
]

# simple one-shot lines for background villagers, keyed by npc_id
const FLAVOR := {
	"bus_driver": [
		["Driver", "Last stop! Everybody down."],
		["Driver", "Village is just up the road, boy. Mind the goats."],
	],
	"villager_ama": [
		["Auntie Ama", "Eh! You are Agya's grandson? You have her eyes."],
		["Auntie Ama", "Greet the Chief before anything else. That is how it is done here."],
	],
	"villager_kwesi": [
		["Old Kwesi", "The farm road is past your grandmother's house. Keep walking east."],
		["Old Kwesi", "The forest beyond the ranch... nobody cuts wood there anymore."],
	],
	"bus_sign": [
		["", "A faded sign. \"VILLAGE - 1 km\". An arrow points east."],
	],
}


#---- objective --------------------------------------------------------------------------------------
func objective() -> String:
	var gs := GameState
	if not gs.has_flag("met_chief"):
		return "Walk into the village and greet the Chief."
	if not gs.has_flag("met_woman"):
		return "Go to Grandma's house."
	if gs.day == 0:
		return "Explore the village, then rest in your room at Grandma's."
	if not gs.has_flag("daily_tasks_given"):
		return "Speak with Grandma."
	var todo: Array[String] = []
	if not gs.has_flag("daily_farm_done"):
		todo.append("tend the farm")
	if not gs.has_flag("daily_herd_done"):
		todo.append("herd the cattle into the pen")
	if not todo.is_empty():
		var text := " and ".join(todo)
		return text[0].to_upper() + text.substr(1) + "."
	return "Head home and rest."


#---- presence ---------------------------------------------------------------------------------------
func is_present(npc_id: String) -> bool:
	match npc_id:
		"woman":
			# she only ever appears once the sun goes down
			return GameState.is_dark()
		"bus_driver":
			return GameState.day == 0
	return true


#---- levels -----------------------------------------------------------------------------------------
func on_level_entered(level_id: String) -> void:
	if level_id == "bus_stop" and not GameState.has_flag("intro_seen"):
		GameState.set_flag("intro_seen")
		await Dialogue.say([
			["", "A message from Mother, three days ago:"],
			["", "\"Kojo, your grandmother is ill. Go to the village and look after her. I will send what I can.\""],
			["", "The bus wheezes away, leaving you at the edge of the village as the sun goes down."],
			[KOJO, "Grandma's village... It's been years."],
		])


#---- talking ----------------------------------------------------------------------------------------
func talk(npc_id: String) -> void:
	match npc_id:
		"chief":
			await _talk_chief()
		"grandma":
			await _talk_grandma()
		"woman":
			await _talk_woman()
		_:
			await Dialogue.say(FLAVOR.get(npc_id, [["", "..."]]))


func _talk_chief() -> void:
	if not GameState.has_flag("met_chief"):
		await Dialogue.say([
			[CHIEF, "Ah. A new face at this hour. Come closer."],
			[KOJO, "Good evening, Nana. I am Kojo, grandson of Agya."],
			[CHIEF, "Agya's grandson! She has spoken of you. You have come because she is unwell."],
			[CHIEF, "Good. A family must hold its own. Her farm and her cattle cannot wait for her to recover."],
			[CHIEF, "Go to her house now. Then come and see me if you need anything. Welcome home, Kojo."],
		])
		GameState.set_flag("met_chief")
	elif GameState.day == 0:
		await Dialogue.say([[CHIEF, "Go on. Your grandmother's house is to the east."]])
	else:
		await Dialogue.say([[CHIEF, "Keep her land alive, Kojo. The village is watching - kindly, I hope."]])


func _talk_grandma() -> void:
	if GameState.day == 0:
		await Dialogue.say([["", "Grandma is fast asleep. Her breathing is slow and shallow."]])
		return

	if GameState.has_flag("daily_tasks_given"):
		if GameState.has_flag("daily_farm_done") and GameState.has_flag("daily_herd_done"):
			await Dialogue.say([[GRANDMA, "You did well today. Go and rest, my child."]])
		else:
			await Dialogue.say([[GRANDMA, "The farm, and the cattle. Go on, before the day is gone."]])
		return

	var lines: Array = []
	if not GameState.has_flag("got_tasks"):
		# first proper conversation - she never mentions the young woman
		lines = [
			[GRANDMA, "Kojo...? Is that you? Come, let me see you."],
			[KOJO, "I'm here, Grandma. Mother sent me. How are you feeling?"],
			[GRANDMA, "Old. Tired. But the land does not care how an old woman feels."],
			[GRANDMA, "The farm needs tending every day, and the cattle must be herded into the pen."],
			[GRANDMA, "The cattle are everything we have. Protect them at all cost."],
			[GRANDMA, "The farm is east of the village, and the ranch is just past it. Go now."],
		]
	else:
		lines = [
			[GRANDMA, "Good morning, Kojo."],
			[GRANDMA, GRANDMA_RULES[(GameState.day - 2) % GRANDMA_RULES.size()]],
			[GRANDMA, "Now - the farm, and the cattle."],
		]
	await Dialogue.say(lines)
	GameState.set_flag("got_tasks")
	GameState.set_flag("daily_tasks_given")


func _talk_woman() -> void:
	if not GameState.has_flag("met_woman"):
		await Dialogue.say([
			["", "A young woman sits beside the bed, wringing out a cloth."],
			[WOMAN, "Shh. She's only just fallen asleep."],
			[KOJO, "I'm Kojo - her grandson. Who are you?"],
			[WOMAN, "Someone who looks after her."],
			[WOMAN, "She drifts in and out these days. Let her rest tonight. Come back tomorrow."],
			[WOMAN, "Your room is through the back. Go on."],
		])
		GameState.set_flag("met_woman")
		GameState.set_time(GameState.TimeOfDay.NIGHT)
		return

	if GameState.day == 0:
		await Dialogue.say([[WOMAN, "Tomorrow, Kojo. Your room is through the back."]])
		return

	var night_lines := [
		[[WOMAN, "You smell of the farm. Good. She'll be glad."]],
		[[WOMAN, "Did she say anything about me today?"], [KOJO, "...No."], [WOMAN, "Mm. She wouldn't."]],
		[[WOMAN, "Don't wake her. Sleep, Kojo. I'll sit with her."]],
	]
	await Dialogue.say(night_lines[GameState.day % night_lines.size()])


#---- sleeping ---------------------------------------------------------------------------------------
func try_sleep() -> void:
	var can_sleep := false
	if GameState.day == 0:
		can_sleep = GameState.has_flag("met_woman")
	else:
		can_sleep = GameState.has_flag("daily_farm_done") and GameState.has_flag("daily_herd_done")

	if not can_sleep:
		var reason := "It's too early to sleep. There's still work to do."
		if not GameState.has_flag("met_woman"):
			reason = "You should see Grandma first."
		await Dialogue.say([["", reason]])
		return

	var next_day := GameState.day + 1
	await SceneRouter.transition(LEVELS.kojo_room, "bed", "Day %d" % next_day, GameState.start_next_day)


#---- farm & ranch tasks -----------------------------------------------------------------------------
func tasks_active() -> bool:
	return GameState.has_flag("daily_tasks_given")


## Called by crop plots / cattle after each one is done. When every node in
## the group is finished the daily task completes.
func check_task(group: String) -> void:
	var task_flag := "daily_farm_done" if group == "crop_plot" else "daily_herd_done"
	if GameState.has_flag(task_flag):
		return
	for node in get_tree().get_nodes_in_group(group):
		if not node.is_done():
			return
	GameState.set_flag(task_flag)
	GameState.add_money(TASK_PAY)

	var done_line := "The crops are watered and weeded." if group == "crop_plot" \
		else "All the cattle are safe in the pen."
	var lines: Array = [["", "%s  (+%d cedis)" % [done_line, TASK_PAY]]]
	if GameState.has_flag("daily_farm_done") and GameState.has_flag("daily_herd_done"):
		GameState.set_time(GameState.TimeOfDay.EVENING)
		lines.append(["", "The sun is going down. Time to head home."])
	await Dialogue.say(lines)
