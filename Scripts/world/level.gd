@tool
class_name Level
extends Node2D
## Root script for every playable level (outdoor area or room).
## Builds the sky/ground backdrop + floor collision, tints for time of day,
## places the player at the spawn marker the SceneRouter asked for, and tells
## Story the level was entered.
##
## Layout convention: the floor is at y = 600, x runs 0..level_width.
## Spawn points are Marker2D children of a "Spawns" node; "default" is the fallback.

const GROUND_Y := 608.0

@export var level_id := ""
@export var location_name := ""
@export var level_width := 1280.0:
	set(value):
		level_width = value
		queue_redraw()
@export var interior := false
@export var enable_collision := true
@export var sky_color := Color(0.55, 0.75, 0.95):
	set(value):
		sky_color = value
		queue_redraw()
@export var ground_color := Color(0.42, 0.32, 0.2):
	set(value):
		ground_color = value
		queue_redraw()

var _tint: CanvasModulate


func _ready() -> void:
	z_index = 0
	if Engine.is_editor_hint():
		return
	if enable_collision == true:
		_build_collision()
	_tint = CanvasModulate.new()
	add_child(_tint)
	GameState.changed.connect(_apply_time)
	_apply_time()
	_place_player()
	HUD.show_location(location_name)
	HUD.refresh()
	# let the scene fade in before any arrival dialogue starts
	while SceneRouter.is_busy():
		await get_tree().process_frame
	Story.on_level_entered(level_id)


func _draw() -> void:
	# drawn on the root, so it sits behind every child
	draw_rect(Rect2(-640, -800, level_width + 1280, GROUND_Y + 800), sky_color)
	draw_rect(Rect2(-640, GROUND_Y, level_width + 1280, 400), ground_color)
	#draw_line(Vector2(-640, GROUND_Y), Vector2(level_width + 640, GROUND_Y), ground_color.darkened(0.4), 3)


func _build_collision() -> void:
	var body := StaticBody2D.new()
	body.name = "LevelBounds"
	add_child(body)
	# floor, plus invisible walls at both ends
	_add_box(body, Rect2(-640, GROUND_Y, level_width + 1280, 200))
	_add_box(body, Rect2(-100, -1000, 100, GROUND_Y + 1000))
	_add_box(body, Rect2(level_width, -1000, 100, GROUND_Y + 1000))


func _add_box(body: StaticBody2D, rect: Rect2) -> void:
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.get_center()
	body.add_child(shape)


func _apply_time() -> void:
	match GameState.time:
		GameState.TimeOfDay.MORNING:
			_tint.color = Color.WHITE
		GameState.TimeOfDay.EVENING:
			_tint.color = Color(0.9, 0.8, 0.75) if interior else Color(1.0, 0.78, 0.62)
		GameState.TimeOfDay.NIGHT:
			_tint.color = Color(0.75, 0.68, 0.6) if interior else Color(0.42, 0.48, 0.72)


func _place_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var spawns := get_node_or_null("Spawns")
	if spawns:
		var marker := spawns.get_node_or_null(GameState.spawn_id) as Node2D
		if marker == null:
			marker = spawns.get_node_or_null("default") as Node2D
		if marker:
			player.global_position = marker.global_position

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.limit_left = 0
		camera.limit_right = int(level_width)
		camera.limit_bottom = int(GROUND_Y + 90)
		camera.reset_smoothing()
