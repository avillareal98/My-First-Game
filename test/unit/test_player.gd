extends "res://addons/gut/test.gd"

var Player = load("res://scripts/character/player/Player.gd")

func test_can_create_player():
	var p = Player.new()
	assert_not_null(p)

func test_get_set_velocity():
	var p = Player.new()
	
