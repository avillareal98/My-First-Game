extends Area2D

export (String, FILE, "*.tscn,*.scn") var path
export (Vector2) var player_spawn_location

func _on_AreaSceneChanger_body_entered(body):
	if path:
		Globals.player_position = player_spawn_location
		SceneChanger.change_scene(path)
