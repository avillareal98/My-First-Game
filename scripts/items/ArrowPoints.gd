extends Area2D

var taken = false

func init(pos):
	global_position = pos

func _on_ArrowPoints_body_entered(body):
	if body.stored_energy < Globals.MAX_ENERGY && !taken && Globals.abilities.can_shoot:
		taken = true
		body.absorb_energy()
		$AnimatedSprite.play("shrink")
		yield($AnimatedSprite, "animation_finished")
		set_collision_mask_bit(0, false)
		queue_free()
