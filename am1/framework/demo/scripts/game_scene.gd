class_name GameScene
extends Node

## ゲームシーンを管轄するクラス

@onready var bgm_player := $BgmPlayer as AudioPlayer

## ゲームの状態の列挙子
enum State {
	None = -1,
	Boot,
	Game,
	GameOver	
}

## 現在のゲームの状態
var current_state = State.None

## 次のゲームの状態
var next_state = State.Boot

## 初期化処理
func _ready():
	SceneChanger.set_init_scene_method(_init_game)

func _process(_delta):
	# 状態切り替え
	_change_state()

	# 更新処理
	_process_state()

## 状態切り替え処理
func _change_state():
	if next_state == State.None:
		return
	
	current_state = next_state
	next_state = State.None

	match current_state:
		State.GameOver:
			_change_game_over()


## ゲームシーンの初期化
func _init_game():
	# 解放処理を登録
	SceneChanger.release_scenes.connect(_release_game_scene)
	
	# カバーを外す
	await SceneChanger.uncover(1.0)

	# 操作開始
	next_state = State.Game
	GameState.control_on()
	bgm_player.play_bgm()

## 更新処理
func _process_state():
		# 操作不可時は処理なし
	if !GameState.can_control:
		return

	match current_state:
		State.Game:
			_process_game()

## ゲーム状態の更新
func _process_game():
	if Input.is_action_just_pressed("Accept"):
		print("Accept")
	if Input.is_action_just_pressed("GameOver"):
		next_state = State.GameOver
	

## ゲームシーンを解放する処理
func _release_game_scene():
	SceneChanger.free_scenes(["Game", "GameOver"])

## ゲームオーバーに切り替え
func _change_game_over():
	GameState.control_off()
	SceneChanger.async_load_scenes(["res://am1/framework/demo/scenes/game_over.tscn"])
	SceneChanger.wait_async_scenes_loaded()

