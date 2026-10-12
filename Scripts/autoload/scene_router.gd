extends CanvasLayer
## Fades between levels and remembers which spawn marker to use on arrival.
## Usage:  SceneRouter.go("res://Scenes/Levels/village.tscn", "from_bus_stop")

var _fade: ColorRect
var _card: Label
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 0.0
	add_child(_fade)

	_card = Label.new()
	_card.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_card.add_theme_font_size_override("font_size", 42)
	_card.modulate.a = 0.0
	add_child(_card)


func is_busy() -> bool:
	return _busy


func go(scene_path: String, spawn_id := "") -> void:
	await transition(scene_path, spawn_id)


## Fade out, optionally run `between` (e.g. advance the day) and show a title
## card, then load the scene and fade back in.
func transition(scene_path: String, spawn_id := "", card_text := "", between := Callable()) -> void:
	if _busy:
		return
	_busy = true
	GameState.input_locked = true

	await _tween_alpha(_fade, 1.0, 0.35)
	if between.is_valid():
		between.call()
	if card_text != "":
		_card.text = card_text
		await _tween_alpha(_card, 1.0, 0.4)
		await get_tree().create_timer(1.0).timeout
		await _tween_alpha(_card, 0.0, 0.4)

	GameState.spawn_id = spawn_id
	get_tree().change_scene_to_file(scene_path)
	# wait for the new scene to be in the tree before revealing it
	await get_tree().process_frame
	await get_tree().process_frame

	await _tween_alpha(_fade, 0.0, 0.35)
	GameState.input_locked = false
	_busy = false


func _tween_alpha(node: CanvasItem, alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", alpha, duration)
	await tween.finished
