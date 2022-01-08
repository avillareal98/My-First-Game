extends Node2D

onready var area = $Area2D
onready var collision = $KinematicBody2D/CollisionShape2D

func init(pos):
	global_position = pos

func _physics_process(delta):
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.get_name() == "Player":
			if body.aura.visible == true:
				collision.disabled = true
			else:
				collision.disabled = false

