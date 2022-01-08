extends Sprite

func dash_effect():
	$AlphaTween.interpolate_property(self, "modulate", Color(1,1,1,0.6), Color(1,1,1,0), .3, Tween.TRANS_SINE, Tween.EASE_OUT)
	$AlphaTween.start()

func return_dash_effect():
	$AlphaTween.interpolate_property(self, "modulate", Color(0,0.976471,1,0.67), Color(1,1,1,0), .5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$AlphaTween.start()

func _on_AlphaTween_tween_completed(object, key):
	queue_free()
