extends Node

## タイトル制御クラス

func _ready():
	var change_data = SceneChangeData.new()
	change_data.screen_cover = ""
	change_data.async_load_scenes = ["", ""]
	change_data.release_scenes = ["", ""]
	change_data.sync_load_scenes = ["", ""]
	SceneChanger.change_scene(change_data)

