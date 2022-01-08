extends StaticBody2D

func init(pos):
	global_position = pos

func destroy_rock_tiles():
	var anim_node = $AnimatedSprite
	if anim_node.animation == "default":
		if anim_node.frame == 0:
			anim_node.frame = 1
		elif anim_node.frame == 1:
			anim_node.frame = 2
		elif anim_node.frame == 2:
			queue_free()
