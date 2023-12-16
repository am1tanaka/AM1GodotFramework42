extends Node

## タイトル制御クラス

func _ready():
	var change_data = SceneChangeData.new()
	change_data.screen_cover = "res://am1/framework/scenes/fade.tscn"
	change_data.cover_color = Color(1.0, 1.0, 1.0, 1.0)
	change_data.cover_seconds = 1.0
	change_data.async_load_scenes = ["", ""]
	change_data.release_scenes = ["", ""]
	change_data.sync_load_scenes = ["", ""]
	SceneChanger.change_scene(change_data)

