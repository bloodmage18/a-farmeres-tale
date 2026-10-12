@tool
class_name Block
extends Node2D
## Blockout shape: a coloured box standing on its origin (bottom-centre) with an
## optional label above it. Use for buildings/props until real art exists.

@export var size := Vector2(100, 100):
	set(value):
		size = value
		queue_redraw()
@export var color := Color(0.5, 0.5, 0.5):
	set(value):
		color = value
		queue_redraw()
@export var label := "":
	set(value):
		label = value
		queue_redraw()


func _draw() -> void:
	Block.draw_box(self, size, color, label)


static func draw_box(canvas: CanvasItem, box_size: Vector2, box_color: Color, text: String) -> void:
	var rect := Rect2(-box_size.x / 2.0, -box_size.y, box_size.x, box_size.y)
	canvas.draw_rect(rect, box_color)
	canvas.draw_rect(rect, box_color.darkened(0.45), false, 2.0)
	if text != "":
		var font := ThemeDB.fallback_font
		var width := maxf(box_size.x, 240.0)
		var pos := Vector2(-width / 2.0, -box_size.y - 10)
		canvas.draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, 16, 5, Color(0, 0, 0, 0.8))
		canvas.draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, 16, Color(1, 1, 1, 0.95))
