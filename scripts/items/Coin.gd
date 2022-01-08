extends Area2D

var taken = false

func init(pos):
	global_position = pos

func _on_Coin_body_entered(body):
	if not taken:
		taken = true
		$AnimationPlayer.play("bounce")
		get_tree().call_group("Gamestate", "coined_up")
		set_collision_mask_bit(0, false)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
