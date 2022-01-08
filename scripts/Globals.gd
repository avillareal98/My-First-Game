extends Node

const UNIT_SIZE = 16
var max_jump_height = 2.25 * UNIT_SIZE
var jump_duration = 0.5
var gravity = 2 * max_jump_height / pow(jump_duration, 2)
var up_gravity = gravity / 2

const MAX_ENERGY = 5

var player_position = null

var player setget ,_get_player

var Player_Camera
var input_disabled = false

# unlockable abilities
var MAX_JUMP_COUNT = 1
var unlockable_abilities = {}
var abilities = {
	"can_double_jump": false,
	"can_wall_jump": false, 
	"can_shoot": false,
	"can_dash": false,
	"can_crouch": false,
	"can_crawl": false,
	"can_slide": false
}
#var can_wall_jump = false
#var can_shoot = false
#var can_dash = false
#var can_crouch = false
#var can_crawl = false
#var can_slide = false
#var n_orbs = 0

func _reset_globals():
	MAX_JUMP_COUNT = 1
	abilities = {
		"can_double_jump": false,
		"can_wall_jump": false, 
		"can_shoot": false,
		"can_dash": false,
		"can_crouch": false,
		"can_crawl": false,
		"can_slide": false
	}
#	can_wall_jump = false
#	can_shoot = false
#	can_dash = false
#	can_crouch = false
#	can_crawl = false
#	can_slide = false
#	n_orbs = 0

func _get_player():
	return player if is_instance_valid(player) else null
