extends Area2D

var can_interact = false
onready var animationplayer = $AnimationPlayer

func _on_Checkpoint_body_entered(body):
	if body.name == "Player":
		print("press 'e'")
		can_interact = true

func _on_Checkpoint_body_exited(body):
	if body.name == "Player":
		can_interact = false

func _input(event):
	if Input.is_action_pressed("interact") && can_interact:
		animationplayer.play("checkpoint")
		get_parent().get_parent().get_node("Player").spawn_point = global_position
		PlayerStats._set_health(PlayerStats.max_health)

