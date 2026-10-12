@tool
class_name NPC
extends Interactable
## A character the player can talk to. Presence and dialogue both come from
## Story using npc_id, so the same NPC can come and go with the time of day.

@export var npc_id := ""


func _init() -> void:
	prompt = "Talk"
	box_size = Vector2(50, 110)
	box_color = Color(0.75, 0.55, 0.35)


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	GameState.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	visible = Story.is_present(npc_id)


func interact() -> void:
	await Story.talk(npc_id)
