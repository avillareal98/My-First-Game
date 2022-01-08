extends Node2D

var initial_pos

func _ready():
	hide()
	initial_pos = position

func _unhandled_input(event):
	if event.is_action_pressed("left"):
		position = Vector2(-initial_pos.x, initial_pos.y)
	elif event.is_action_pressed("right"):
		position = initial_pos
