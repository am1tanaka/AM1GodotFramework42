extends Node

## SceneChanger.

const sub_scene_changer : PackedScene = preload("res://am1/framework/scenes/sub_scene_changer.tscn")

## 画面を覆って、読み込みや解放が完了したら呼び出す処理
signal covered_loaded_unloaded
## シーンを解放する処理
signal release_scenes

## スクリーンを覆う処理のインスタンス
var cover_instance: ScreenCover

## 最初の起動フラグ
var first_boot: bool = true

func _ready():
	var sub = sub_scene_changer.instantiate()
	add_child(sub)
	
	# 画面を覆う
	cover_instance = sub.get_node("Fade") as ScreenCover
	cover_instance.start_cover(Color(1.0, 1.0, 1.0, 1.0), 0)

func change_scene(data: SceneChangeData):
	print("change scene "+data.screen_cover)
	var fade_scene = load(data.screen_cover)
	add_child(fade_scene)

	# TODO 画面を隠しておくノードをreleaseを呼び出して削除

	var fade = fade_scene as Fade
	fade.start_cover(data.cover_color, data.cover_seconds)

## シーンの初期化を実行するシーン
func set_init_scene_method(init_method: Callable):
	GameState.control_off()
	if first_boot:
		first_boot = false
		init_method.call()
	else:
		covered_loaded_unloaded.connect(init_method)

## 画面の覆いを解除
func uncover(sec: float):
	cover_instance.start_uncover(sec)
	await cover_instance.wait_tween()
	cover_instance.queue_free()
	
