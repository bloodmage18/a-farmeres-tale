extends CanvasLayer
## Always-on HUD: day / time / money (top left), current objective (top right),
## and a location banner that fades in when a level loads.

var _status: Label
var _objective: Label
var _location: Label
var _location_tween: Tween


func _ready() -> void:
	layer = 40
	_build_ui()
	GameState.changed.connect(refresh)
	refresh()


func refresh() -> void:
	if GameState.day == 0:
		_status.text = "Arrival  -  %s" % GameState.time_name()
	else:
		_status.text = "Day %d  -  %s      Cedis: %d" % [GameState.day, GameState.time_name(), GameState.money]
	_objective.text = "Objective:  " + Story.objective()


func show_location(location: String) -> void:
	if location == "":
		return
	_location.text = location
	if _location_tween:
		_location_tween.kill()
	_location.modulate.a = 0.0
	_location_tween = create_tween()
	_location_tween.tween_property(_location, "modulate:a", 1.0, 0.4)
	_location_tween.tween_interval(1.6)
	_location_tween.tween_property(_location, "modulate:a", 0.0, 0.8)


func _build_ui() -> void:
	_status = _make_label(20)
	_status.position = Vector2(20, 14)
	add_child(_status)

	_objective = _make_label(18)
	_objective.anchor_left = 1.0
	_objective.anchor_right = 1.0
	_objective.offset_left = -620
	_objective.offset_right = -20
	_objective.offset_top = 14
	_objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_objective)

	_location = _make_label(36)
	_location.anchor_left = 0.0
	_location.anchor_right = 1.0
	_location.offset_top = 90
	_location.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_location.modulate.a = 0.0
	add_child(_location)


func _make_label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	return label
