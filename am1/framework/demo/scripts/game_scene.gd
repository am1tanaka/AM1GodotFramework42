extends Node

## ゲームシーンを管轄するクラス

## 初期化処理
func _ready():
	SceneChanger.set_init_scene_method(init_game)

## ゲームシーンの初期化
func init_game():
	# 解放処理を登録
	SceneChanger.release_scenes.connect(release_game_scene)
	
	# カバーを外す
	await SceneChanger.uncover(1.0)

	# 操作開始
	GameState.control_on()

## ゲームシーンを解放する処理
func release_game_scene():
	queue_free()
