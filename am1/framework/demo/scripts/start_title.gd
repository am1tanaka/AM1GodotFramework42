extends Node

## タイトルシーンに切り替える処理
## このスクリプトがアタッチされているシーンをSceneChanger.chnage_scene()に渡すことで
## シーンがSceneChanger配下に生成される。
## サブシーンに登録されたら_enter_treeが自動的に呼び出されるので切り替えシーケンスを実行する。
## この処理は前のシーンが実行されている状態で動く。

func _enter_tree():
	
	## 画面覆い開始
	var fade = SceneChanger.load_cover("res://am1/framework/scenes/fade.tscn") as ScreenCover
	AudioPlayer
	fade.start_cover(Color(0.0, 0.0, 0.0, 0.0), 1.0)

	## シーン読み込み開始
	SceneChanger.async_load_scenes(["res://am1/framework/demo/scenes/title.tscn"])
	
	## 画面覆い完了待ち
	await SceneChanger.wait_and_init_scenes()

	## 切り替えが終わったら解放
	queue_free()
