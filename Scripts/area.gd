extends Node2D

@export var area_color: Color = Color.WHITE


func _draw():
	draw_rect(
		Rect2(0, 0, 800, 600),
		area_color,
		false,
		5.0
	)


func _ready():
	queue_redraw()
