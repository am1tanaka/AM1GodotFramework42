extends Node

## タイトルからゲームシーンを開始する処理

func _enter_tree():
	var fade = await SceneChanger.load_cover("res://am1/framework/scenes/fade.tscn") as ScreenCover
	
	## 画面覆い開始
	fade.start_cover(Color(0.0, 0.0, 0.0, 0.0), 1.0)

	## シーン読み込み開始
	SceneChanger.async_load_scenes(["res://am1/framework/demo/scenes/game.tscn"])
	
	## 画面覆い完了待ち
	await SceneChanger.wait_cover_finished()

	## シーンを解放する
	SceneChanger.release_scenes.emit()
	
	## シーンの読み込み完了を待って、シーンの初期化メソッドを呼び出す
	SceneChanger.init_scene(self)
	SceneChanger.covered_loaded_unloaded.emit()
