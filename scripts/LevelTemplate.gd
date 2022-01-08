extends Node2D

onready var lava_hazards = $Hazards/Lava
onready var breakable_tiles = $DestroyedBlocks/Bricks
onready var rocks = $DestroyedBlocks/Rocks
onready var enemies = $Enemies/Prototype
onready var barriers = $Barriers

onready var lava = preload("res://scenes/hazards/LavaHazard.tscn")
onready var brick = preload("res://scenes/destructible_objects/Bricks.tscn")
onready var rock = preload("res://scenes/destructible_objects/Rock.tscn")
onready var enemy = preload("res://scenes/character/enemies/Enemy.tscn")
onready var barrier = preload("res://scenes/items/Barrier.tscn")

var coined = 0

func _ready():
	add_to_group("Gamestate")
	_auto_set_limits()
	spawn_tiles()
	lava_hazards.hide()
	breakable_tiles.hide()
	rocks.hide()
	barriers.hide()
	spawn_enemies()
	enemies.hide()
	update_GUI()
	
	if Globals.player_position:
		$Player.global_position = Globals.player_position

func _auto_set_limits():
	var map_size = $Platform/Platforms.get_used_rect()
	var cell_size = $Platform/Platforms.cell_size
	$Player/Camera2D.limit_left = map_size.position.x * cell_size.x
	$Player/Camera2D.limit_top = map_size.position.y * cell_size.y
	$Player/Camera2D.limit_right = map_size.end.x * cell_size.x
	$Player/Camera2D.limit_bottom = map_size.end.y * cell_size.y

func spawn_tiles():
	# lava
	for cell in lava_hazards.get_used_cells():
		var tile = lava.instance()
		var pos = lava_hazards.map_to_world(cell)
		pos = pos + lava_hazards.position
		tile.init(pos + lava_hazards.cell_size/2)
		add_child(tile)
	
	# bricks
	for cell in breakable_tiles.get_used_cells():
		var tile = brick.instance()
		var pos = breakable_tiles.map_to_world(cell)
		pos = pos + breakable_tiles.position
		tile.init(pos + breakable_tiles.cell_size/2)
		add_child(tile)
	
	# rocks
	for cell in rocks.get_used_cells():
		var tile = rock.instance()
		var pos = rocks.map_to_world(cell)
		pos = pos + rocks.position
		tile.init(pos + rocks.cell_size/2)
		add_child(tile)
	
	# barriers
	for cell in barriers.get_used_cells():
		var tile = barrier.instance()
		var pos = barriers.map_to_world(cell)
		pos = pos + barriers.position
		tile.init(pos + barriers.cell_size/2)
		add_child(tile)

func spawn_enemies():
	for cell in enemies.get_used_cells():
		var tile = enemy.instance()
		var pos = enemies.map_to_world(cell)
		pos = pos + enemies.position
		tile.init(pos + enemies.cell_size/2)
		add_child(tile)

func coined_up():
	coined += 1
	update_GUI()

func update_GUI():
	get_tree().call_group("GUI", "update_GUI", coined)


