extends Node

## ゲームシーンを管轄するクラス

## 初期化処理
func _ready():
	SceneChanger.set_init_scene_method(_init_game)

func _process(delta):
	if !GameState.can_control:
		return

	if Input.is_action_just_pressed("Accept"):
		print("Accept")
	if Input.is_action_just_pressed("GameOver"):
		print("GameOver")

## ゲームシーンの初期化
func _init_game():
	# 解放処理を登録
	SceneChanger.release_scenes.connect(_release_game_scene)
	
	# カバーを外す
	await SceneChanger.uncover(1.0)

	# 操作開始
	GameState.control_on()

## ゲームシーンを解放する処理
func _release_game_scene():
	queue_free()
