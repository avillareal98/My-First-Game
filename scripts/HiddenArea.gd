extends Node2D

onready var hidden_area = $Area2D/TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	hidden_area.visible = true;

func _on_Area2D_body_entered(body):
	hidden_area.visible = false;
