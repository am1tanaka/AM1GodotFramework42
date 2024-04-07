extends Node

## タイトルからゲームシーンを開始する処理
## このスクリプトがアタッチされているシーンをSceneChanger.chnage_scene()に渡すことで
## シーンがSceneChanger配下に生成される。
## サブシーンに登録されたら_enter_treeが自動的に呼び出されるので切り替えシーケンスを実行する。
## この処理は前のシーンが実行されている状態で動く。

func _enter_tree():
	## 画面覆い開始
	var fade = SceneChanger.load_cover("res://am1/framework/scenes/fade.tscn") as ScreenCover	
	fade.start_cover(Color.BLACK, 1.0)

	## シーン読み込み開始
	var scenes = LoadScenes.new()
	scenes.scenes = [
		LoadSceneData.new("res://am1/framework/demo/scenes/game.tscn")
	]
	SceneChanger.change_scenes_and_wait_covered(scenes)

	## 切り替えが終わったら解放
	queue_free()
