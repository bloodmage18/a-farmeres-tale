extends CanvasLayer
## Light-novel style text box.
## Usage:  await Dialogue.say([["Kojo", "Hello."], ["", "Narration line."]])
## An empty speaker is narration.

signal finished

const CHARS_PER_SEC := 60.0

var _lines: Array = []
var _index := 0
var _opened_frame := 0
var _typing := false

var _panel: PanelContainer
var _name_label: Label
var _text_label: Label
var _hint_label: Label


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_panel.hide()


func is_open() -> bool:
	return _panel.visible


func say(lines: Array) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_index = 0
	_opened_frame = Engine.get_process_frames()
	GameState.input_locked = true
	_panel.show()
	_show_line()
	await finished


func _show_line() -> void:
	var line = _lines[_index]
	var speaker: String = line[0]
	_name_label.text = speaker
	_name_label.visible = speaker != ""
	_text_label.text = line[1]
	# narration reads in italics-ish grey, speech in white
	_text_label.modulate = Color(0.8, 0.8, 0.85) if speaker == "" else Color.WHITE
	_text_label.visible_ratio = 0.0
	_typing = true
	_hint_label.hide()


func _process(delta: float) -> void:
	if not _typing:
		return
	var total := maxf(1.0, _text_label.text.length())
	_text_label.visible_ratio = minf(1.0, _text_label.visible_ratio + CHARS_PER_SEC * delta / total)
	if _text_label.visible_ratio >= 1.0:
		_finish_typing()


func _finish_typing() -> void:
	_typing = false
	_text_label.visible_ratio = 1.0
	_hint_label.show()


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	# the key press that opened the box must not also skip the first line
	if Engine.get_process_frames() == _opened_frame:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("enter") \
			or event.is_action_pressed("ui_accept") or event.is_action_pressed("left_click"):
		get_viewport().set_input_as_handled()
		if _typing:
			_finish_typing()
			return
		_index += 1
		if _index < _lines.size():
			_show_line()
		else:
			_close()


func _close() -> void:
	_panel.hide()
	_lines = []
	GameState.input_locked = false
	finished.emit()


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.anchor_left = 0.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = 80
	_panel.offset_right = -80
	_panel.offset_top = -170
	_panel.offset_bottom = -24
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.07, 0.06, 0.92)
	style.border_color = Color(0.85, 0.7, 0.4)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(16)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var box := VBoxContainer.new()
	_panel.add_child(box)

	_name_label = Label.new()
	_name_label.add_theme_color_override("font_color", Color(0.95, 0.75, 0.35))
	_name_label.add_theme_font_size_override("font_size", 20)
	box.add_child(_name_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text_label.add_theme_font_size_override("font_size", 20)
	box.add_child(_text_label)

	_hint_label = Label.new()
	_hint_label.text = "[E] continue"
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.modulate = Color(1, 1, 1, 0.6)
	box.add_child(_hint_label)
