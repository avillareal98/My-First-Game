extends StaticBody2D

#const FADE_SCRIPT = preload("res://scripts/destructible_objects/FadeObjects.gd")
#
#var division_parts
#export (int) var min_division_parts = 6
#export (int) var max_division_parts = 12
#
#export (float) var min_width = -1 * 24
#export (float) var max_width = 1 * 24
#
#export (float) var min_height = -1 * 24
#export (float) var max_height = -2 * 24
#
#onready var sprite = $Sprite

func init(pos):
	global_position = pos

#func _ready():
#	randomize()
#	division_parts = int(rand_range(min_division_parts, max_division_parts))

func destroy():
#	var sprite_region = sprite.region_rect
#	var texture = sprite.texture
#
#	var tamX = sprite_region.size.x / division_parts
#	var tamY = sprite_region.size.y / division_parts
#
#	for height in range(division_parts):
#		for width in range(division_parts):
#			var rec = Rect2(sprite_region.position.x + (tamX * width), sprite_region.position.y + (tamY * height), tamX, tamY)
#			var new_sprite = Sprite.new()
#			new_sprite.texture = texture
#			new_sprite.region_enabled = true
#			new_sprite.centered = false
#			new_sprite.region_rect = rec
#			new_sprite.global_position = sprite.global_position + Vector2(tamX * width, tamY * height)
#
#			var rigid_body = RigidBody2D.new()
#			rigid_body.add_child(new_sprite)
#			rigid_body.set_script(FADE_SCRIPT)
#			rigid_body.apply_impulse(Vector2(), Vector2(rand_range(min_width,max_width), rand_range(min_height,max_height)))
#			get_parent().add_child(rigid_body)
	$AnimatedSprite.play("destroy")
	yield($AnimatedSprite, "animation_finished")
	queue_free()
