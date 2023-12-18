extends Node

## タイトル制御クラス

func _ready():
	SceneChanger.set_init_scene_method(init_title)

## タイトルシーンの初期化
func init_title():
	SceneChanger.release_scenes.connect(release_title)
	await SceneChanger.uncover(1.0)
	GameState.control_on()

## 解放
func release_title():
	queue_free()
