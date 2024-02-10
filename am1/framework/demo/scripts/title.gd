extends Node

## タイトル制御クラス

@export var sliders: Array[AM1VolumeSlider]

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
	SceneChanger.release_scenes.connect(release_title)
	await SceneChanger.uncover(1.0)
	GameState.control_on()
	($BgmPlayer as AudioPlayer).play_bgm()

## 解放
func release_title():
	queue_free()
