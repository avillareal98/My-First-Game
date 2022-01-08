extends Node

onready var map = $Platform

func post_import(scene):
	var jtl = map.get_node("Platforms")
	if jtl:
		jtl.tile_set.tile_set_shape_one_way(23, 0, true) # 22 + 1 = id 23
		jtl.tile_set.tile_set_shape_one_way(24, 0, true)
		jtl.tile_set.tile_set_shape_one_way(25, 0, true)
	return scene
