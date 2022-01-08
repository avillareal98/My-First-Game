extends Node2D

onready var anim = $Lever/AnimatedSprite
onready var collisionshape = $Lever/CollisionShape2D

var lever_open = false
var is_near_switch = false

func _physics_process(delta):
	collisionshape.disabled = true
	if is_near_switch:
		check_input()

func _on_Area2D_body_entered(body):
	is_near_switch = true
	get_parent().set_physics_process(true)

func _on_Area2D_body_exited(body):
	is_near_switch = false
	get_parent().set_physics_process(false)

func check_input():
	if Input.is_action_just_pressed("interact"):
		match lever_open:
			true:
				anim.play("up_down")
				lever_open = false
				get_parent().open = false
				get_parent().open_close()
			false:
				anim.play("down_up")
				lever_open = true
				get_parent().open = true
				get_parent().open_close()
				
