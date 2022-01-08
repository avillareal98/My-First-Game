extends Area2D

var heal_amount = 1

func init(pos):
	global_position = pos

func _ready():
	$AnimatedSprite.play("bubble")

func _on_Potion_body_entered(body):
	PlayerStats.heal(heal_amount)
	queue_free()
