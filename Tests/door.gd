extends Area2D

signal player_entered_door_area
signal player_exited_door_area
signal player_entered_room

@export var room : String = ""

@onready var prompt = $Control/VBoxContainer/Prompt
@onready var room_name = $Control/VBoxContainer/RoomName
@onready var description = $Control/VBoxContainer/description


# door dictionary - authored per door in each room scene.
# "name": where it leads,  "description": one short line.
@export var door_data : Dictionary = {
	'name': "",
	'description': ""
}

enum door_state{
	open,
	closed
}
@export var state = door_state.open

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#just in case add what ever node that uses this script to the door group
	self.add_to_group("door")

func _unhandled_input(event: InputEvent) -> void:
	if get_overlapping_bodies():
		if Input.is_action_just_pressed("enter"):
			match state:
				door_state.open:
					#player is entering the room
					print("player trying to enter room ")
					emit_signal("player_entered_room" , room)
				door_state.closed:
					print("the door is locked - access to room denied")

func enter() -> void:
	# programmatic entry for the AI (equivalent to the player pressing forward
	# while overlapping this door)
	match state:
		door_state.open:
			emit_signal("player_entered_room", room)
		door_state.closed:
			print("the door is locked - access to room denied")

func _on_body_entered(body) -> void:
	# enrich the authored data with a live prompt based on lock state
	var info := door_data.duplicate()
	info["prompt"] = "Press F / X to enter" if state == door_state.open else "Locked"
	prompt.text = info["prompt"]
	room_name.text = info["name"]
	description.text = info["description"]
	emit_signal("player_entered_door_area", info)

func _on_body_exited(body) -> void:
	emit_signal("player_exited_door_area")
	prompt.text = ""
	room_name.text = ""
	description.text = ""
