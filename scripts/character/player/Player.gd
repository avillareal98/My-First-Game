extends KinematicBody2D

signal grounded_update(is_grounded)
#signal health_updated(health)
#signal killed()
signal death()

const RockProjectile_PS = preload("res://scenes/weapons/ArrowProjectile.tscn")
const PRE_DASH_EFFECT = preload("res://scenes/character/player/DashEffect.tscn")

const UP = Vector2(0, -1)
const SLOPE_STOP = 16
const DROP_THRU_BIT = 6
const SLOPE_STOP_THRESHOLD = 16.0
const WALL_JUMP_VELOCITY = Vector2(100, -200)
const BOUNCE_VELOCITY = -200

#export (int) var max_health = 1
#var health = max_health setget _set_health

export (int) var hit_damage = 1

var velocity = Vector2()
var move_speed = 5 * Globals.UNIT_SIZE
var max_jump_velocity
var min_jump_velocity
var move_direction
var move_input_speed = 0
var facing = 0
var wall_direction = 1
var held_item = null
export var bottom_limit = 180

var is_jumping = false
var is_grounded = false

var jump_count = 0

var min_jump_height = 0.8 * Globals.UNIT_SIZE

var gravity_disabled = false
var movement_speed_while_attack = 0 * 24

onready var dashcooldownnode = $DashCooldown
onready var dash_velocity = 30 * Globals.UNIT_SIZE
var dash_cooldown = 1.0

var spawn_point = Vector2(0,0)

var energy_level = 0
var stored_energy = 0

var blocking_speed = 150
var blocking = false setget set_blocking
var current_speed = move_speed

onready var camera = $Camera2D
onready var raycasts = $Raycasts
onready var anim_player = $Character
onready var drop_thru_raycasts = $DropThruRaycasts
onready var held_item_position = $Character/HeldItemPosition
onready var bounce_raycasts = $BounceRaycasts
onready var left_wall_raycasts = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts = $WallRaycasts/RightWallRaycasts
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer
onready var invulnerability_timer = $InvulnerabilityTimer
onready var effects_animation = $EffectsAnimation
onready var label = $StateLabel
onready var aura = $Aura
onready var arrowdetectioncircle = $ArrowDetectionCircle
onready var charge_energy_timer = $ChargeEnergyTimer
onready var label2 = $Label
onready var shield = $Shield
onready var playercanvaslayer = $CanvasLayer/HeartUI

onready var state_machine = $StateMachine
onready var action_state_machine = $ActionStateMachine

func _ready():
	aura.visible = false
	max_jump_velocity = -sqrt(2 * Globals.gravity * Globals.max_jump_height)
	min_jump_velocity = -sqrt(2 * Globals.gravity * min_jump_height)
	Globals.player = self
	
	PlayerStats.connect("killed", self, "on_Player_killed")
	
	dashcooldownnode.wait_time = dash_cooldown
	
	Globals.Player_Camera = camera
	
	spawn_point = global_position
	
	arrowdetectioncircle.disconnect("area_entered", arrowdetectioncircle, "_on_ArrowDetectionCircle_area_entered")
	
	arrowdetectioncircle.visible = false
	#label2.text = "E:" + str(energy_level) + "/" + str(stored_energy)
	get_tree().call_group("GUI", "update_weapon_GUI", energy_level, stored_energy)

func _update_label(energy_level, stored_energy):
	#var text = "E:" + str(energy_level) + "/" + str(stored_energy)
	#label2.text = text
	get_tree().call_group("GUI", "update_weapon_GUI", energy_level, stored_energy)

func _apply_gravity(delta):
	velocity.y += Globals.gravity * delta
	
	if is_jumping && velocity.y >= 0:
		is_jumping = false

func _cap_gravity_wall_slide():
	var max_velocity = Globals.UNIT_SIZE if !Input.is_action_pressed("down") else 6 * Globals.UNIT_SIZE
	velocity.y = min(velocity.y, max_velocity)

func _apply_movement(delta):
	var snap = Vector2.DOWN * 8 if !is_jumping else Vector2.ZERO
	if move_direction == 0 && abs(velocity.x) < SLOPE_STOP_THRESHOLD:
		velocity.x = 0
	#var stop_on_slope = true if get_floor_velocity().x == 0 else false
	_check_bounce(delta)
	#velocity = move_and_slide_with_snap(velocity, snap, UP, stop_on_slope) 
	velocity = move_and_slide_with_snap(velocity, snap, UP) #UP is the normal to the floor
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.has_method("collide_with"):
			collision.collider.collide_with(collision, self)
	
	var was_grounded = is_grounded
	is_grounded = is_on_floor()
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_update", is_grounded)
	is_grounded = _check_is_grounded() && get_collision_mask_bit(DROP_THRU_BIT) && !is_jumping
	_try_again()

func _try_again():
	if position.y > bottom_limit:
		global_position = spawn_point
		PlayerStats._set_health(PlayerStats.max_health)
#		_set_health(max_health)

func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))

func _handle_move_input(var move_speed = self.move_speed):
	move_direction = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
	#get movement keypresses, convert to integers and then store in move_direction
	move_input_speed = -Input.get_action_strength("left") + Input.get_action_strength("right")
	if state_machine.state == state_machine.states.attack:
		velocity.x = lerp(velocity.x, movement_speed_while_attack * move_input_speed, _get_h_weight())
	else:
		velocity.x = lerp(velocity.x, move_speed * move_input_speed, _get_h_weight()) #linear interpolation
#	if gravity_disabled:
#		velocity.x = 0
	if move_direction != 0:
		anim_player.scale.x = move_direction
		$SwordAttack.scale.x = move_direction
		#facing = move_direction

func _handle_wall_slide_sticking():
	if move_direction != 0 && move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()

func _get_h_weight():
	if is_on_floor():
		return 0.2
	else:
		if move_direction == 0:
			return 0.02
		elif move_direction == sign(velocity.x) && abs(velocity.x) > move_speed:
			return 0.0
		else:
			return 0.1

func jump():
	velocity.y = max_jump_velocity
	is_jumping = true

func wall_jump():
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity

func _check_is_grounded(raycasts = self.raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	#if loop completes then raycast was not detected
	return false

func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	
	if is_near_wall_left && is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)

func _check_is_valid_wall(wall_raycasts):
	for raycasts in wall_raycasts.get_children():
		if raycasts.is_colliding():
			var dot = acos(Vector2.UP.dot(raycasts.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				return true
	return false

func _on_Area2D_body_exited(body):
	set_collision_mask_bit(DROP_THRU_BIT, true)

func spawn_projectile():
	if held_item == null:
		held_item = RockProjectile_PS.instance()
		held_item_position.add_child(held_item)
		held_item_position.position.x = 16
		held_item_position.position.y = 0

func _throw_held_item():
	held_item.launch(facing)
	held_item = null
	energy_level -= 1
	is_aura_visible(energy_level)

func damage(attacker, amount):
	if blocking and is_shield_facing(attacker.global_position):
		return
	elif invulnerability_timer.is_stopped():
		jump()
		invulnerability_timer.start()
		PlayerStats._set_health(PlayerStats.health - amount)
#		_set_health(health - amount)
		effects_animation.play("damage")
		effects_animation.queue("flash")

func on_Player_killed():
	emit_signal("death")
	global_position = spawn_point
	PlayerStats._set_health(PlayerStats.max_health)

#func kill():
#	global_position = spawn_point
#	_set_health(max_health)

#func _set_health(value):
#	var prev_health = health
#	health = clamp(value, 0, max_health)
#	if health != prev_health:
#		emit_signal("health_updated", health)
#		if health == 0:
#			kill()
#			emit_signal("killed")

func _on_InvulnerabilityTimer_timeout():
	effects_animation.play("rest")

# BOUNCE
# ----------------------------------------

func _check_bounce(delta):
	if velocity.y > 0:
		for raycast in bounce_raycasts.get_children():
			raycast.cast_to = Vector2.DOWN * velocity * delta + Vector2.DOWN
			raycast.force_raycast_update()
			if raycast.is_colliding() && raycast.get_collision_normal() == Vector2.UP:
				velocity.y = (raycast.get_collision_point() - raycast.global_position - Vector2.DOWN).y / delta
				raycast.get_collider().entity.call_deferred("be_bounced_upon", self)
				break

func bounce(bounce_velocity = BOUNCE_VELOCITY):
	velocity.y = bounce_velocity

#func heal(amount):
#	if health < max_health:
#		_set_health(health + amount)

# SHOOT
# ----------------------------------------

func _energy_level_up():
	if energy_level < Globals.MAX_ENERGY:
		energy_level += 1
		stored_energy -= 1
	is_aura_visible(energy_level)
	_update_label(energy_level, stored_energy)

func _detect_energy():
	arrowdetectioncircle.connect("area_entered",arrowdetectioncircle,"_on_ArrowDetectionCircle_area_entered")
	arrowdetectioncircle.visible = true

func _stop_energy_detection():
	arrowdetectioncircle.disconnect("area_entered",arrowdetectioncircle,"_on_ArrowDetectionCircle_area_entered")
	arrowdetectioncircle.visible = false

func absorb_energy():
	if stored_energy < Globals.MAX_ENERGY:
		stored_energy += 1
		_update_label(energy_level, stored_energy)

func is_aura_visible(energy_levels):
	if energy_levels > 0:
		aura.visible = true
	else:
		aura.visible = false

# ATTACK
# ----------------------------------------

func _on_SwordAttack_body_entered(body):
	if body.has_method("destroy_rock_tiles"):
		body.destroy_rock_tiles()
	elif body.is_in_group("enemy"):
		if state_machine.state == state_machine.states.attack:
			body.damage(hit_damage, self)

# DASH
# ----------------------------------------

func get_input_direction():
	var input_direction = Vector2()
	input_direction.x = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
	input_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return input_direction

func dash_movement():
	global_position.x = clamp(global_position.x, camera.limit_left, camera.limit_right)
	var movement = move_and_slide(velocity, Vector2.UP)

func dash(input_direction):
	$GhostTimer.start()
	$DashDuration.start()
	if input_direction == Vector2.ZERO:
		input_direction.x = anim_player.scale.x
	
	if input_direction.x != 0 and input_direction.y != 0:
		velocity = (dash_velocity / sqrt(2)) * input_direction
	else:
		velocity = dash_velocity * input_direction

func _on_DashDuration_timeout():
	$GhostTimer.stop()
	if is_on_floor():
		state_machine.set_state(state_machine.states.idle)
	else:
		state_machine.set_state(state_machine.states.fall)

func _on_DashCooldown_timeout():
	var ghost_effect = PRE_DASH_EFFECT.instance()
	get_parent().add_child(ghost_effect)
	ghost_effect.dash_effect()
	ghost_effect.global_position = $Character.global_position
	ghost_effect.scale.x = $Character.scale.x
	ghost_effect.texture = $Character.frames.get_frame($Character.animation, $Character.frame)

func _on_GhostTimer_timeout():
	var ghost_effect = PRE_DASH_EFFECT.instance()
	get_parent().add_child(ghost_effect)
	ghost_effect.return_dash_effect()
	ghost_effect.global_position = $Character.global_position
	ghost_effect.scale.x = $Character.scale.x
	ghost_effect.texture = $Character.frames.get_frame($Character.animation, $Character.frame)

# SHIELD
# ----------------------------------------
func is_shield_facing(hit_position):
	var shield_direction = sign(shield.global_position.x - global_position.x)
	var hit_direction = sign(global_position.x - hit_position.x)
	return shield_direction != hit_direction

func set_blocking(value):
	blocking = value
	shield.visible = value
	current_speed = blocking_speed if value else move_speed

# Unlockable abilities
# ----------------------------------------
func unlock_ability(ability_name):
	if Globals.abilities.has(ability_name):
		Globals.abilities[ability_name] = true
		print(ability_name)
