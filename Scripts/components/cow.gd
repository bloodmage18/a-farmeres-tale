@tool
class_name Cow
extends Interactable
## One head of cattle. Press E to drive it into the pen; pen every cow in the
## level to finish the herding task. Resets each morning.

## Local position (in the level) the cow walks to when herded
@export var pen_spot := Vector2.ZERO
@export var wander_range := 60.0

const WALK_SPEED := 160.0

var _home_x := 0.0
var _t := 0.0
var _walking := false


func _init() -> void:
	prompt = "Herd"
	box_size = Vector2(90, 60)
	box_color = Color(0.85, 0.82, 0.75)
	label = "Cow"


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	add_to_group("cattle")
	_home_x = position.x
	_t = randf() * TAU
	if is_done():
		position = pen_spot


func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint() or is_done() or _walking:
		return
	# lazy grazing sway until herded
	_t += delta * 0.5
	position.x = _home_x + sin(_t) * wander_range


func is_done() -> bool:
	return GameState.has_flag("daily_cow_" + name)


func get_prompt() -> String:
	return "" if is_done() or _walking else prompt


func interact() -> void:
	if is_done() or _walking:
		return
	if not Story.tasks_active():
		await Dialogue.say([["", "The cattle graze lazily. Grandma will tell you what needs doing."]])
		return
	_walking = true
	var tween := create_tween()
	tween.tween_property(self, "position", pen_spot, position.distance_to(pen_spot) / WALK_SPEED)
	await tween.finished
	_walking = false
	GameState.set_flag("daily_cow_" + name)
	await Story.check_task("cattle")
