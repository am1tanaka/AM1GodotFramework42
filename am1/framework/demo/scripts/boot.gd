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
	if cover:
		cover.start_cover(cover_color, 0)

	## シーン読み込み開始
	SceneChanger.change_scenes_and_wait_covered(_load_scenes)
