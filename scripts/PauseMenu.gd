extends Control

var scene_path_to_load

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("pause"):
		var new_pause_state = !get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state

func _on_ContinueButton_pressed():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state

func _on_QuitToMainMenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/MainMenu.tscn")
