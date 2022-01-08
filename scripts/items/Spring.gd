extends Node2D

onready var animation_player = $AnimationPlayer

func be_bounced_upon(bouncer):
	if bouncer.has_method("bounce"):
		bouncer.bounce()
		animation_player.play("boing")
