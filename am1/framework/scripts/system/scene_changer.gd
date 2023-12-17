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

## 非同期読み込み中のシーン名
var async_load_scene_pathes: Array[String]

func _ready():
	var sub = sub_scene_changer.instantiate()
	add_child(sub)
	
	# 画面を覆う
	cover_instance = sub.get_node("Fade") as ScreenCover
	cover_instance.start_cover(Color(1.0, 1.0, 1.0, 1.0), 0)

## シーン切り替えを処理するシーンパスを受け取って、シーン切り替えを開始
func change_scene(change_scene_path):
	# 操作禁止
	GameState.control_off()

	# 切り替えシーンの読み込み
	if ResourceLoader.load_threaded_request(change_scene_path) != Error.OK:
		print("change scene error: "+change_scene_path)
		return
	
	# 読み込み待ち
	var scene = await ResourceLoader.load_threaded_get(change_scene_path)
	var scene_instance = scene.instantiate()
	add_child(scene_instance)

## シーンの初期化を実行するシーン
func set_init_scene_method(init_method: Callable):
	GameState.control_off()
	if first_boot:
		first_boot = false
		init_method.call()
	else:
		covered_loaded_unloaded.connect(init_method)

## 指定のパスのシーンを読み込んで、子ノードにしてインスタンスを返す
func load_cover(cover_path) -> ScreenCover:
	if ResourceLoader.load_threaded_request(cover_path) != Error.OK:
		print("load_cover error:"+cover_path)
		return
	
	var cover_node = await ResourceLoader.load_threaded_get(cover_path)
	cover_instance = cover_node.instantiate()
	get_tree().root.add_child(cover_instance)
	return cover_instance

## 画面の覆いを解除
func uncover(sec: float):
	cover_instance.start_uncover(sec)
	await cover_instance.wait_cover()
	cover_instance.queue_free()

## 非同期でシーンの読み込みを開始
func async_load_scenes(scene_pathes: Array[String]):
	for path in scene_pathes:
		# すでに読み込み中なら処理しない
		if async_load_scene_pathes.has(path):
			continue
		
		# 読み込み開始
		if ResourceLoader.load_threaded_request(path) != Error.OK:
			print("Load Error: "+path)
			return
		
		async_load_scene_pathes.append(path)

## 画面を覆う処理の完了を待つ
func wait_cover_finished():
	if cover_instance:
		await cover_instance.wait_cover

## シーンの読み込み完了と
func init_scene(parent_scene: Node):
	# TODO 進捗シーンを表示

	# 読み込み完了待ち
	for path in async_load_scene_pathes:
		var status = ResourceLoader.load_threaded_get_status(path)
		
		# 読み込み待ち
		while (status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS):
			await get_tree().process_frame
			status = ResourceLoader.load_threaded_get_status(path)

		# エラーチェック
		if status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			print("Load Error: "+path)
			continue

	# シーンの作成と子ノード	
	for path in async_load_scene_pathes:
		var scene = ResourceLoader.load_threaded_get(path)
		var scene_instance = scene.instantiate()
		parent_scene.add_child(scene_instance)
		
	# パスを解放
	async_load_scene_pathes.clear()
