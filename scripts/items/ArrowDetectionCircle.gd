extends Area2D

#var find_arrow

func _on_ArrowDetectionCircle_area_entered(area):
	connect("body_entered", self, "_on_ArrowDetectionCircle_body_entered")

func _on_ArrowDetectionCircle_body_entered(body):
	get_parent().effects_animation.play("charge")
	if get_parent().stored_energy > 0:
		get_parent()._energy_level_up()
