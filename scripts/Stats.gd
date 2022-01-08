extends Node

signal health_updated(health)
signal max_health_updated(health)
signal killed()

export (int) var max_health = 1 setget _set_max_health
var health = max_health setget _set_health

func _set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_updated", max_health)

func _set_health(value):
	health = value
	emit_signal("health_updated", health)
	if health <= 0:
		emit_signal("killed")

func heal(amount):
	if health < max_health:
		_set_health(health + amount)

func _ready():
	self.health = max_health

