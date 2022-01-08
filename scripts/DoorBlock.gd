extends Node2D

export var open = false

onready var anim = $AnimationPlayer
onready var camera = $Camera2D
onready var timer = $Timer
onready var collisionshape = $KinematicBody2D/CollisionShape2D
export var camera_pan = true

var init

func _ready():
	init = true
	open_close()
	camera.zoom = Vector2(0.5,0.5)
	timer.set_wait_time(1.5)
	set_physics_process(false)
	init = false

func open_close():
	if camera_pan && !init:
		camera.make_current()
		Globals.input_disabled = true
	timer.start()
	match open:
		true:
			anim.play("down_up")
			yield(anim, "animation_finished")
			open = false
			collisionshape.disabled = true
		false:
			anim.play_backwards("down_up")
			yield(anim, "animation_finished")
			open = true
			collisionshape.disabled = false

func _on_Timer_timeout():
	Globals.input_disabled = false
	if camera_pan && !init:
		Globals.Player_Camera.make_current()
