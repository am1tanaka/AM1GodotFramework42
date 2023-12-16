extends Node

## SceneChanger.

const sub_scene_changer : PackedScene = preload("res://am1/framework/scenes/sub_scene_changer.tscn")

func _ready():
	var sub = sub_scene_changer.instantiate()
	add_child(sub)
	# TODO 画面を隠しておくノードを取得。release()メソッドで削除できるようにしておく

func change_scene(data: SceneChangeData):
	print("change scene "+data.screen_cover)
	var fade_scene = load(data.screen_cover)
	add_child(fade_scene)

	# TODO 画面を隠しておくノードをreleaseを呼び出して削除

	var fade = fade_scene as Fade
	fade.start_fade_out(data.cover_color, data.cover_seconds, fade_in_done)

## フェードインが完了した時に実行する処理
func fade_in_done():
	pass
	
	
