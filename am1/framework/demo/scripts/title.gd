extends Node

## タイトル制御クラス

@export var sliders: Array[AM1VolumeSlider]
@export var _game_scenes: LoadScenes

@onready var _bgm_player := $BgmPlayer as AudioPlayer

## シーンが開始したら初期化関数を登録
func _ready():
	SceneChanger.set_init_scene_method(init_title)

	for slider in sliders:
		var storage = AM1AudioVolumeConfigFile.new()
		slider.init(storage)
		
	# 効果音スライダーに効果音ボリュームの変更を設定
	sliders[2].volume_changed.connect(func(): SystemSePlayer.player.play(SEPlayer.Clip.Click))

## タイトルシーンの初期化
func init_title():
	await SceneChanger.uncover(1.0)
	GameState.control_on()
	_bgm_player.play_bgm()

## ゲーム開始ボタン
func _on_start_button_pressed():
	if GameState.can_control:
		SystemSePlayer.player.play(SEPlayer.Clip.Start)
		_cold_start_game()
		_bgm_player.fade_out(0.5)

func _cold_start_game():
	## 画面覆い開始
	var fade = SceneChanger.load_cover("res://am1/framework/scenes/fade.tscn") as ScreenCover	
	fade.start_cover(Color.BLACK, 1.0)

	## シーン読み込み開始
	SceneChanger.change_scenes_and_wait_covered(_game_scenes)
