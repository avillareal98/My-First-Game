extends KinematicBody2D

const GRAVITY = 20
const UP = Vector2(0, -1)

var move_speed = 24
var velocity = Vector2()
var direction = -1
export (int) var max_health = 3
onready var health = max_health setget _set_health

var invulnerable = false
var death = false

onready var anim_enemy = $Character
onready var raycasts = $RayCasts
onready var ground_raycast = $GroundRayCasts/RayCast2D
onready var detection_timer = $DetectionTimer
onready var invulnerability_timer = $InvulnerabilityTimer
onready var hitarea_collision = $Hitbox/CollisionShape2D
onready var damagearea_collision = $DamageArea/CollisionShape2D

export (Array, PackedScene) var scene

const MIN_X = 10.0
const MAX_X = 80.0

func _ready():
	add_to_group("enemy")
	randomize()

func init(pos):
	global_position = pos

func apply_speed():
	velocity.x = move_speed * direction

func apply_gravity():
	velocity.y += GRAVITY

func apply_movement():
	var snap_vector = Vector2.DOWN * 32
	velocity = move_and_slide_with_snap(velocity, snap_vector, UP)

func update_move_direction():
	if is_on_wall():
		direction *= -1
		ground_raycast.position.x *= -1
		hitarea_collision.position.x *= -1
		damagearea_collision.position.x *= -1
		for raycast in raycasts.get_children():
			raycast.cast_to.x *= -1
	if !is_grounded(ground_raycast):
		direction *= -1
		ground_raycast.position.x *= -1
		hitarea_collision.position.x *= -1
		damagearea_collision.position.x *= -1
		for raycast in raycasts.get_children():
			raycast.cast_to.x *= -1

func update_facing():
	if direction == -1:
		anim_enemy.flip_h = false
	else:
		anim_enemy.flip_h = true

func is_player_detected(raycastss):
	for raycast in raycastss.get_children():
		if raycast.is_colliding():
			return true
	return false

func damage(amount, node = null):
	if !invulnerable:
		invulnerable = true
		_set_health(health - amount)
		$AnimationPlayer.play("damage")

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		print("enemy health: " + str(health))
		if health == 0:
			death = true
			drop_object()

func is_grounded(ground_raycasts):
	if ground_raycasts.is_colliding():
		return true

func drop_object():
	var enemypos = self.global_position
	var xloc = enemypos.x
	var yloc = enemypos.y
	
	var potion = scene[0].instance()
	potion.position = Vector2(xloc, yloc)
	get_parent().call_deferred("add_child", potion)
	
	var coins = []
	for i in range(0, 3):
		coins.append(scene[1].instance())
		coins[i].position = Vector2(xloc, yloc)
		get_parent().call_deferred("add_child", coins[i])
	
	var tween = Tween.new()
	add_child(tween)
	
	for coin in coins:
		var dir = 1 if randi() % 2 == 0 else -1
		var goal = coin.position + Vector2(rand_range(MIN_X, MAX_X), 0) * dir;
		print(goal)
		
		tween.interpolate_property(coin, "position:x", null,
			goal.x, 1, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	
	tween.start()
