extends Node2D

func _ready():
	fade()

func fade():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		self, 
		"modulate",
		Color(1,1,1,1),
		Color(1,1,1,0),
		1,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		0
	)
	tween.start()
	yield(tween,"tween_completed")
	yield(get_tree(),"idle_frame")
	queue_free()
