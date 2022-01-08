extends KinematicBody2D

const THROW_VELOCITY = Vector2(250, 0)

var velocity = Vector2.ZERO

export (int) var hit_damage = 1

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	#velocity.y += Globals.gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		_on_impact(collision.normal)
		if collision.collider.has_method("destroy"):
			collision.collider.destroy()
		elif collision.collider.has_method("damage"):
			collision.collider.damage(hit_damage)
		elif collision.collider.has_method("destroy_rock_tiles"):
			collision.collider.destroy_rock_tiles()

func launch(target_position):
	$Timer.start()
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	
	#target_position += Vector2(rand_range(-64, 64), rand_range(-64, 64))
	#var arc_height = target_position.y - global_position.y - 32
	#arc_height = min(arc_height, -32)
	#velocity = PhysicsHelper.calculate_arc_velocity(global_position, target_position, arc_height)
	#velocity = velocity.clamped(500)
	#velocity = velocity.rotated(rand_range(-0.1, 0.1))
	
	#velocity = THROW_VELOCITY * Vector2(target_position, 1)
	
	velocity = THROW_VELOCITY.rotated(deg2rad(target_position))
	set_physics_process(true)

func _on_impact(normal : Vector2):
	velocity = velocity.bounce(normal)
	velocity *= 0 + rand_range(-0.05, 0.05)

func _on_Timer_timeout():
	$Projectile.play("explode")
	yield($Projectile, "animation_finished")
	queue_free()

