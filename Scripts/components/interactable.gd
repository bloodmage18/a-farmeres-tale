@tool
class_name Interactable
extends Area2D
## Base for anything the player can stand in front of and press E on.
## Origin is at the feet (bottom-centre). Draws its own blockout box so it is
## visible in the editor; subclasses override interact().

@export var prompt := "Interact"
@export var box_size := Vector2(60, 120):
	set(value):
		box_size = value
		queue_redraw()
@export var box_color := Color(0.6, 0.6, 0.6):
	set(value):
		box_color = value
		queue_redraw()
@export var label := "":
	set(value):
		label = value
		queue_redraw()

var _player_inside := false
var _prompt_label: Label


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	collision_layer = 0
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(maxf(box_size.x, 60.0), box_size.y)
	shape.shape = rect
	shape.position = Vector2(0, -box_size.y / 2.0)
	add_child(shape)

	_prompt_label = Label.new()
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.size = Vector2(240, 24)
	# keep the prompt above Kojo's head even for short things like crop plots
	_prompt_label.position = Vector2(-120, -maxf(box_size.y, 110.0) - 60)
	_prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_prompt_label.add_theme_constant_override("outline_size", 5)
	_prompt_label.hide()
	add_child(_prompt_label)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _draw() -> void:
	Block.draw_box(self, box_size, box_color, label)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var show := _player_inside and is_available() and not GameState.input_locked and get_prompt() != ""
	_prompt_label.visible = show
	if show:
		_prompt_label.text = "[E] " + get_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _player_inside or not is_available() or GameState.input_locked or SceneRouter.is_busy():
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("enter"):
		get_viewport().set_input_as_handled()
		interact()


#---- overridables -----------------------------------------------------------------------------------
func is_available() -> bool:
	return visible


func get_prompt() -> String:
	return prompt


func interact() -> void:
	pass


func on_player_entered() -> void:
	pass


#---- signals ----------------------------------------------------------------------------------------
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		on_player_entered()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
