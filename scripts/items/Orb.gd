extends Area2D

export (String, "can_double_jump", "can_wall_jump", "can_shoot", "can_dash", "can_crouch", "can_crawl", "can_slide") var unlock = "can_double_jump"

func _ready():
	if Globals.unlockable_abilities.has(unlock):
		queue_free()
	connect("body_entered", self, "on_Player_body_entered")

func on_Player_body_entered(body):
	body.unlock_ability(unlock)
	queue_free()
