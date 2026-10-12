@tool
class_name CropPlot
extends Interactable
## One patch of the farm. Tend every plot in the level to finish the farm task.
## Progress is a daily flag, so plots reset each morning.

const DRY := Color(0.45, 0.3, 0.18)
const TENDED := Color(0.3, 0.6, 0.25)


func _init() -> void:
	prompt = "Tend crops"
	box_size = Vector2(120, 30)
	box_color = DRY


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	add_to_group("crop_plot")
	box_color = TENDED if is_done() else DRY


func is_done() -> bool:
	return GameState.has_flag("daily_crop_" + name)


func get_prompt() -> String:
	return "" if is_done() else prompt


func interact() -> void:
	if is_done():
		return
	if not Story.tasks_active():
		await Dialogue.say([["", "The soil is dry. Better speak with Grandma before touching her crops."]])
		return
	GameState.set_flag("daily_crop_" + name)
	box_color = TENDED
	await Story.check_task("crop_plot")
