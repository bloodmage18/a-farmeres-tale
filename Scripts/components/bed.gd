@tool
class_name Bed
extends Interactable
## Ends the day (if Story allows it) and starts the next morning.


func _init() -> void:
	prompt = "Sleep"
	box_size = Vector2(160, 50)
	box_color = Color(0.55, 0.6, 0.75)
	label = "Bed"


func interact() -> void:
	await Story.try_sleep()
