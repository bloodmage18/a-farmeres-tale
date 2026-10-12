@tool
class_name SceneDoor
extends Interactable
## Moves the player to another level. Use for building doors (press E) and for
## map-edge exits (auto_enter = true, triggers on walking in).
## Optionally gated behind a story flag.

@export_file("*.tscn") var target_scene := ""
## Marker2D name under the target level's "Spawns" node
@export var target_spawn := ""
@export var auto_enter := false
## Story flag that must be set before this door opens (empty = always open)
@export var required_flag := ""
@export_multiline var locked_text := "It's locked."


func _init() -> void:
	prompt = "Enter"
	box_size = Vector2(70, 130)
	box_color = Color(0.36, 0.22, 0.14)


func get_prompt() -> String:
	return "" if auto_enter else prompt


func is_open() -> bool:
	return required_flag == "" or GameState.has_flag(required_flag)


func on_player_entered() -> void:
	if auto_enter and not GameState.input_locked and not SceneRouter.is_busy():
		interact()


func interact() -> void:
	if not is_open():
		await Dialogue.say([["", locked_text]])
		return
	if target_scene == "":
		await Dialogue.say([["", "Nothing here yet."]])
		return
	SceneRouter.go(target_scene, target_spawn)
