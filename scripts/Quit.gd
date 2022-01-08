extends CanvasLayer

func _on_Yes_pressed():
	get_tree().quit()

func _on_No_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
