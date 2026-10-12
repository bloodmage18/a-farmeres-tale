extends Area2D

signal player_entered_scene_area
signal player_exited_scene_area
signal player_entered_next_area

@export var next_scene : PackedScene

@onready var area_name = $Control/VBoxContainer/area_name
@onready var destination_name = $Control/VBoxContainer/destination_name

enum exit_path {
	LEFT,
	RIGHT,
	LOCKED
}
@export var exit_direction = exit_path.LOCKED

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("area_zone")
	
	area_name.text = get_parent().get_parent().name
	
	var loaded_next_scene = next_scene
	#destination_name.text = loaded_next_scene.resource_path
	print(loaded_next_scene , " " , destination_name)
	
	pass # Replace with function body.

func _Area_Processor(body):
	if body.is_in_group("player"):
		match exit_direction:
			exit_path.LEFT:
				#await get_tree().create_timer(0.7 , true).timeout
				if Input.is_action_pressed("left"):
					print("left area zone")
					emit_signal("player_entered_next_area")
					_next_scene(next_scene)
				pass
			exit_path.RIGHT:
				#await get_tree().create_timer(0.7 , true).timeout
				if Input.is_action_pressed("right"):
					print("right area zone")
					emit_signal("player_entered_next_area")
					_next_scene(next_scene)
				pass
			exit_path.LOCKED:
				pass
	
	pass
	
func _next_scene(next_scene):
	emit_signal("player_entered_next_area",next_scene)
	print("going to next scene")

func _on_body_entered(body):
	print("player_entered")
	emit_signal("player_entered_scene_area")
	_Area_Processor(body)
	pass # Replace with function body.


func _on_body_exited(body):
	print("player_exited")
	emit_signal("player_exited_scene_area")
	pass # Replace with function body.
