extends Control

var hearts = 5 setget set_hearts
var max_hearts = 5 setget set_max_hearts

onready var heartuifull = $HeartUIFull
onready var heartuiempty = $HeartUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartuifull != null:
		heartuifull.rect_size.x = value * 16

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartuiempty != null:
		heartuiempty.rect_size.x = value * 16

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_updated", self, "set_hearts")
	PlayerStats.connect("max_health_updated", self, "set_max_hearts")

