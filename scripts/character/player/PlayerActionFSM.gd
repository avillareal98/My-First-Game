extends StateMachine

var taken = false

func _ready():
	add_state("none")
	add_state("shoot_idle")
	add_state("shoot_run")
	add_state("shoot_jump")
	add_state("shoot_fall")
	add_state("charge_arrow")
	call_deferred("set_state", states.none)

func _get_transition(delta):
	match state:
		states.none:
			if Input.is_action_pressed("throw") && can_shoot_idle() && Globals.abilities.can_shoot:
				return states.shoot_idle
			elif Input.is_action_pressed("throw") && can_shoot_run() && Globals.abilities.can_shoot:
				return states.shoot_run
			elif Input.is_action_pressed("throw") && can_shoot_jump() && Globals.abilities.can_shoot:
				return states.shoot_jump
			elif Input.is_action_pressed("throw") && can_shoot_fall() && Globals.abilities.can_shoot:
				return states.shoot_fall
			if Input.is_action_pressed("charge") && can_charge_arrow() && Globals.abilities.can_shoot:
				return states.charge_arrow
		states.shoot_idle:
			if !Input.is_action_pressed("throw") || !can_shoot_idle():
				return states.none
		states.shoot_run:
			if !Input.is_action_pressed("throw") || !can_shoot_run():
				return states.none
		states.shoot_jump:
			if !Input.is_action_pressed("throw") || !can_shoot_jump():
				return states.none
		states.shoot_fall:
			if !Input.is_action_pressed("throw") || !can_shoot_fall():
				return states.none
		states.charge_arrow:
			if !Input.is_action_pressed("charge") || !can_charge_arrow():
				return states.none

func _enter_state(new_state, old_state):
	var main_states = parent.state_machine.states
	match new_state:
		states.none:
			if [main_states.idle].has(parent.state_machine.state):
				parent.anim_player.play("idle")
			elif [main_states.run].has(parent.state_machine.state):
				parent.anim_player.play("run")
			elif [main_states.jump].has(parent.state_machine.state):
				parent.anim_player.play("jump")
			elif [main_states.fall].has(parent.state_machine.state):
				parent.anim_player.play("fall")
		states.shoot_idle:
			parent.anim_player.play("shoot")
		states.shoot_run:
			parent.anim_player.play("shoot_run")
		states.shoot_jump:
			parent.anim_player.play("shoot_jump")
		states.shoot_fall:
			parent.anim_player.play("shoot_fall")
		states.charge_arrow:
			if parent.stored_energy > 0:
				parent._energy_level_up()
	parent.get_node("StateLabel2").text = states.keys()[state]

func can_shoot_idle() -> bool:
	var main_states = parent.state_machine.states
	return ![main_states.run, main_states.jump, main_states.fall, main_states.wall_slide].has(parent.state_machine.state)

func can_shoot_run() -> bool:
	var main_states = parent.state_machine.states
	return ![main_states.idle, main_states.jump, main_states.fall, main_states.wall_slide].has(parent.state_machine.state)

func can_shoot_jump() -> bool:
	var main_states = parent.state_machine.states
	return ![main_states.idle, main_states.run, main_states.fall, main_states.wall_slide].has(parent.state_machine.state)

func can_shoot_fall() -> bool:
	var main_states = parent.state_machine.states
	return ![main_states.idle, main_states.run, main_states.jump, main_states.wall_slide].has(parent.state_machine.state)

func can_charge_arrow() -> bool:
	var main_states = parent.state_machine.states
	return ![main_states.jump, main_states.fall, main_states.wall_slide].has(parent.state_machine.state)

#func _on_ActionStateMachine_state_changed(new_state, old_state):
#	pass
