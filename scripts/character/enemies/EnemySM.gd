extends "res://scripts/states/StateMachine.gd"

var detection = false

func _ready():
	_init_states()
	call_deferred("set_state", states.walk)

func _init_states():
	add_state("walk")
	add_state("attack")
	add_state("hurt")
	add_state("death")

func _state_logic(delta):
	parent.update_move_direction()
	parent.update_facing()
	parent.apply_gravity()
	parent.apply_speed()
	parent.apply_movement()

func _get_transition(delta):
	match state:
		states.walk:
			if parent.death:
				return states.death
			if parent.invulnerable:
				parent.invulnerability_timer.start()
				return states.hurt
			if parent.is_player_detected(parent.raycasts):
				detection = true
				parent.detection_timer.start()
				return states.attack
		states.attack:
			if parent.death:
				return states.death
			if parent.invulnerable:
				parent.invulnerability_timer.start()
				return states.hurt
			if !parent.is_player_detected(parent.raycasts) && detection == false:
				return states.walk
		states.hurt:
			if parent.death:
				return states.death
			if !parent.invulnerable:
				if parent.is_player_detected(parent.raycasts):
					detection = true
					parent.detection_timer.start()
					return states.attack
				elif !parent.is_player_detected(parent.raycasts) && detection == false:
					return states.walk

func _enter_state(new_state, old_state):
	match state:
		states.walk:
			parent.move_speed = 30
			parent.anim_enemy.play("walk")
		states.attack:
			parent.move_speed = 0
			parent.anim_enemy.play("attack")
			yield(parent.anim_enemy, "animation_finished")
			parent.move_speed = 100
			parent.anim_enemy.play("run")
		states.hurt:
			parent.move_speed = 0
			parent.anim_enemy.play("hurt")
		states.death:
			parent.move_speed = 0
			parent.hitarea_collision.disabled = true
			parent.damagearea_collision.disabled = true
			parent.anim_enemy.play("death")
			yield(parent.anim_enemy, "animation_finished")
			parent.queue_free()

func _exit_state(old_state, new_state):
	match old_state:
		states.attack:
			parent.anim_enemy.play("attack", true)
			yield(parent.anim_enemy, "animation_finished")

func _on_DetectionTimer_timeout():
	detection = false

func _on_InvulnerabilityTimer_timeout():
	parent.invulnerable = false
