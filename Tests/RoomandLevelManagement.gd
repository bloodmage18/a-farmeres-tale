extends Node2D


#path to player/ai character
@onready var player : CharacterBody2D = get_node("Node/Player")

# door info labels (populated when standing in a door area)
@onready var door_title: Label = $CanvasLayer/UI_UX/Overlay/HBoxContainer/Object_Labels/Object_Name
@onready var door_prompt: Label = $CanvasLayer/UI_UX/Overlay/HBoxContainer/Object_Labels/Object_Funtion
@onready var door_description: Label = $CanvasLayer/UI_UX/Overlay/HBoxContainer/Object_Labels/Object_Description

# current room labels (populated on entering / while inside a room)
@onready var location_title: Label = $CanvasLayer/UI_UX/Overlay/HBoxContainer/Room_Labels/Current_Location
@onready var location_description: Label = $CanvasLayer/UI_UX/Overlay/HBoxContainer/Room_Labels/Current_Description

#rooms variables
@export_category("room_data")
@export var current_room = null
@export var room_queue_unload = null

const ROOM_SCENE_PATH := "res://Tests/%.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	_connect_doors_in_scene()
	pass # Replace with function body.


#---- room entery funtion --------------------------------------------------------------------------
func _on_room_entered(room):
	# Preload the room scene as a PackedScene
	var room_packed_scene = load(room)
	if room_packed_scene:
		var room_instance = room_packed_scene.instantiate()
		room_instance.name = room.get_file().get_basename()
		if !room_instance.is_in_group("Room"):room_instance.add_to_group("Room")
		# Unload previous room if needed
		room_queue_unload = get_tree().get_nodes_in_group("Room")
		if room_queue_unload:
			# We defer the unloading to prevent issues while loading
			room_queue_unload[0].queue_free()
			room_queue_unload = null

		$Rooms.add_child(room_instance)
		current_room = room_instance.name
		# connect doors in new instanced room
		_connect_doors_in_scene()
		# refresh labels: new room, and we're no longer in a door
		_update_room_labels(room_instance)
		_clear_door_labels()

#---- label update funtions ------------------------------------------------------------------------
func _update_room_labels(room_node) -> void:
	# rooms carry display_name / description as node metadata
	location_title.text = room_node.get_meta("display_name", room_node.name)
	location_description.text = room_node.get_meta("description", "")

func _show_door_labels(door_data) -> void:
	# keep it short: where it goes, how to use it, a one-line hint
	door_title.text = door_data.get("name", "")
	door_prompt.text = door_data.get("prompt", "")
	door_description.text = door_data.get("description", "")

func _clear_door_labels() -> void:
	door_title.text = ""
	door_prompt.text = ""
	door_description.text = ""

#---- doors area funtions --------------------------------------------------------------------------
func _on_door_body_entered(doors_data) -> void:
	#pass in the doors data
	_show_door_labels(doors_data)

func _on_door_body_exited() -> void:
	#if player exited the door area
	_clear_door_labels()

func _connect_doors_in_scene() -> void:
	# connect door signals for new instanced rooms
	for door in get_tree().get_nodes_in_group("Door"):
		if door.is_connected("player_entered_door_area" ,_on_door_body_entered ):
			#print("door signals already connected - ")
			pass
		else:
			door.connect("player_entered_door_area" , _on_door_body_entered)
			door.connect("player_exited_door_area" , _on_door_body_exited)
			door.connect("player_entered_room" , _on_room_entered)
