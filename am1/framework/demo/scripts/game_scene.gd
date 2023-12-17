extends Node

## ゲームシーンを管轄するクラス

## 初期化処理
func _enter_tree():
	SceneChanger.release_scenes.emit()

	SceneChanger.uncover(1.0)
	await SceneChanger.wait_cover_finished()
	
	GameState.control_on()
		
