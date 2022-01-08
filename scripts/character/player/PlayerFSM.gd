extends StateMachine

var hit = false

# Powerup variables
var on_shoot = false

func _ready():
	_init_states()
	call_deferred("set_state", states.idle)

func _init_states():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("attack")
	add_state("death")
	
	# unlockable abilities
	add_state("wall_slide") 
	add_state("dash")
	add_state("crouch")
	add_state("swim")

func _input(event):
	if [states.idle, states.run].has(state):
		if event.is_action_pressed("jump"): # space
			if Input.is_action_pressed("down"): # S key
				if parent._check_is_grounded(parent.drop_thru_raycasts):
					parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)
			else:
				parent.jump()
	elif state == states.wall_slide && Globals.abilities.can_wall_jump:
		if event.is_action_pressed("jump"): # space
			parent.wall_jump()
			set_state(states.jump)
	
	# H key
	if event.is_action_pressed("throw"):
		if parent.energy_level > 0:
			parent.spawn_projectile()
			parent._throw_held_item()
			parent._update_label(parent.energy_level, parent.stored_energy)
	if event.is_action_pressed("left"): # A key
		parent.facing = 180
	elif event.is_action_pressed("right"): # D key
		parent.facing = 0
	if event.is_action_pressed("up"): # W key
		parent.camera.position.y = -150
	if event.is_action_pressed("down"): # S key
		parent.camera.position.y = 150
	if event.is_action_released("up"):
		parent.camera.position.y = 0
	if event.is_action_released("down"):
		parent.camera.position.y = 0
#	elif event.is_action_pressed("up"):
#		parent.facing = -90
#		parent.held_item_position.position.x = 0
#		parent.held_item_position.position.y = -16
#	elif event.is_action_pressed("down"):
#		parent.facing = 90
#		parent.held_item_position.position.x = 0
#		parent.held_item_position.position.y = 16
	
	if event.is_action_pressed("discharge"):
		parent._detect_energy()

	if event.is_action_released("discharge"):
		parent._stop_energy_detection()
	
	#Shield
	if event.is_action_pressed("defend"):
		parent.blocking = true
	elif event.is_action_released("defend"):
		parent.blocking = false
	
	#VARIABLE JUMP
	if Globals.abilities.can_double_jump:
		Globals.MAX_JUMP_COUNT = 2
	if state == states.jump && parent.jump_count < Globals.MAX_JUMP_COUNT:
		parent.anim_player.play("jump")
		parent.jump()
		parent.jump_count += 1
		if event.is_action_released("jump") and parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity

func _state_logic(delta):
	parent._update_move_direction()
	parent._update_wall_direction()
	if state != states.wall_slide:
		parent._handle_move_input()
	if [states.dash].has(state):
		parent.dash_movement()
	else:
		parent._apply_gravity(delta)
	if state == states.wall_slide:
		parent._cap_gravity_wall_slide()
		parent._handle_wall_slide_sticking()
	if state == states.attack:
		if Input.is_action_just_pressed("attack"):
			hit = true
	parent._apply_movement(delta)

func _get_transition(delta):
	match state:
		states.idle:
			if Input.is_action_just_pressed("dash") && parent.dashcooldownnode.is_stopped() && Globals.abilities.can_dash:
				return states.dash
			elif Input.is_action_just_pressed("attack"):
				return states.attack
			elif !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if Input.is_action_just_pressed("dash") and parent.dashcooldownnode.is_stopped() && Globals.abilities.can_dash:
				return states.dash
			elif Input.is_action_just_pressed("attack"):
				return states.attack
			elif !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if Input.is_action_just_pressed("attack"):
				return states.attack
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped() && Globals.abilities.can_wall_jump:
				return states.wall_slide
			elif Input.is_action_just_pressed("dash") && parent.dashcooldownnode.is_stopped() && Globals.abilities.can_dash:
				return states.dash
			elif parent.velocity.y >= 0:
				return states.fall
			elif parent.is_on_floor():
				return states.idle
		states.fall:
			if Input.is_action_just_pressed("attack"):
				return states.attack
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped() && Globals.abilities.can_wall_jump:
				return states.wall_slide
			elif Input.is_action_just_pressed("dash") && parent.dashcooldownnode.is_stopped() && Globals.abilities.can_dash:
				return states.dash
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		states.wall_slide:
			if parent.is_on_floor():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
		states.dash:
			pass
	
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.anim_player.play("idle")
			#print("Enter idle")
		states.run:
			parent.anim_player.play("run")
			#print("Enter run")
		states.jump:
			parent.anim_player.play("jump")
			parent.jump_count = 0 
			#print("Enter jump")
		states.fall:
			parent.anim_player.play("fall")
			#print("Enter fall")
		states.wall_slide:
			parent.anim_player.play("wall_slide")
			parent.anim_player.scale.x = -parent.wall_direction
			#print("Enter wall-slide")
		states.attack:
			attack()
		states.dash:
			var input_direction = parent.get_input_direction()
			parent.dashcooldownnode.start()
			parent.dash(input_direction)
	parent.get_node("StateLabel").text = states.keys()[state]

func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wall_slide_cooldown.start()
		states.attack:
			yield(get_tree(), "idle_frame")
#			parent.movement_speed_while_attack = 0 * 24
#			parent.gravity_disabled = false
			parent.get_node("SwordAttack/CollisionShape2D").disabled = true
		states.dash:
			parent.velocity = parent.velocity * 0.10

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)

#func is_charging_arrow() -> bool:
#	var arrow_states = parent.action_state_machine.states
#	return [arrow_states.charge_arrow].has(parent.action_state_machine.state)

func attack():
	parent.anim_player.play("attack")
#	parent.movement_speed_while_attack = 4 * 24
	hit = false

func _on_Character_animation_finished():
	var anim_name = parent.get_node("Character").animation
	if hit:
		if state == states.attack:
			if parent.is_on_floor():
				attack()
		return
	if anim_name == "attack":
		hit = false
		set_state(previous_state)

func _on_Character_frame_changed():
	var anim_node = parent.get_node("Character")
	var attack_collision_shape = parent.get_node("SwordAttack/CollisionShape2D")
	if anim_node.animation == "attack":
		if anim_node.frame == 1:
			attack_collision_shape.disabled = false
		elif anim_node.frame == 4:
			attack_collision_shape.disabled = true
#			parent.movement_speed_while_attack = 0
