extends Node

## 起動用スクリプト

## 画面を覆うシーンの色
@export var cover_color := Color.BLACK

## 画面を覆うシーンのパス
@export_file("*.tscn") var _cover_scene_path

## 最初のシーンを読み込むスクリプト
@export var _load_scenes: LoadScenes

## 最初のシーンを読み込む処理
func _enter_tree():
	## 画面覆い開始
	var cover = SceneChanger.load_cover(_cover_scene_path) as ScreenCover
	cover.start_cover(cover_color, 0)

	## シーン読み込み開始
	var files = []
	#for p in _load_scene_paths:
	#	files.append(p.file_path)
	SceneChanger.async_load_scenes(files)

	## シーンの読み込み完了を待って、シーンの初期化メソッドを呼び出す
	SceneChanger.wait_and_init_scenes()

	## 切り替えが終わったら解放
	queue_free()

