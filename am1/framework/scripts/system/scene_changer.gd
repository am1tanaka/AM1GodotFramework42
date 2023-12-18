extends Node

## シーンの遷移を管理するクラス。[br]
## 最初に起動するシーンの_ready関数でset_init_scene_method()に初期化メソッドを渡して呼び出す。
## set_init_scene_method()に渡す初期化メソッドの例は以下の通り。[br]
## @tutorial(シーンの管理クラス):      https://datgm23.github.io/AM1GodotFramework42/docs/examples/scene_manage_class.md
## @tutorial(シーンを切り替えるクラス): https://datgm23.github.io/AM1GodotFramework42/docs/examples/change_scene_sequence.md

## 最初に画面を覆うシーン
const _start_cover: PackedScene = preload("res://am1/framework/scenes/fade.tscn")

## 画面を覆って、読み込みや解放が完了したら呼び出すシグナル
signal covered_loaded_unloaded

## シーンを解放するときに実行するシグナル
signal release_scenes

## スクリーンを覆う処理のインスタンス
var _cover_instance: ScreenCover

## 最初の起動フラグ
var _first_boot: bool = true

## 非同期読み込み中のシーン名
var _async_load_scene_pathes: Array[String]

## 画面を覆うシーンや初期化などを持たせるためのサブシーンを作成してサブシーンにする。
## また、最初のフェードを取得して、画面を覆っておく。
func _ready():
	# 画面を覆う
	_cover_instance = _start_cover.instantiate()
	add_child(_cover_instance)
	_cover_instance.start_cover(Color(1.0, 1.0, 1.0, 1.0), 0)

## シーン切り替えをするときに、シーンの読み込みなどのシーケンスを処理するスクリプトのパスを渡して呼び出す。[br]
## [param change_scene_script_path] 切り替え処理を実行するスクリプトのパス
func change_scene(change_scene_script_path):
	# 操作禁止
	GameState.control_off()

	# 切り替えシーンの読み込み
	if ResourceLoader.load_threaded_request(change_scene_script_path) != Error.OK:
		push_error("change scene error: "+change_scene_script_path)
		return
	
	# 読み込み待ち
	var script = ResourceLoader.load_threaded_get(change_scene_script_path)
	var script_instance = script.new()
	add_child(script_instance)

## メインシーンの_readyから呼び出される。
## 初回起動のときはすぐに渡された初期化メソッドを呼び出して最初のシーンを開始する。
## ２回目以降に呼び出されたときは渡されたメソッドをcovered_laoded_uncoveredにconnectして、
## 次のシーンの読み込みや画面を覆う演出を終えてからemitする。[br]
## [param init_method] 画面を覆って非同期読み込みが完了したら呼び出す初期化処理[br]
func set_init_scene_method(init_method: Callable):
	GameState.control_off()

	if _first_boot:
		_first_boot = false
		init_method.call()
	else:
		covered_loaded_unloaded.connect(init_method)

## 指定のパスのシーンを読み込んで、子ノードにしてインスタンスを返す。[br]
## [param cover_path] 画面を覆うシーンのパス
func load_cover(cover_path) -> ScreenCover:
	if ResourceLoader.load_threaded_request(cover_path) != Error.OK:
		push_error("load_cover error:"+cover_path)
		return
	
	var _cover_node = ResourceLoader.load_threaded_get(cover_path)
	_cover_instance = _cover_node.instantiate()
	get_tree().root.add_child(_cover_instance)
	return _cover_instance

## 画面の覆いを解除する。awaitで解除を待つことができる。
## [param sec] 画面の覆いを解除する秒数
func uncover(sec: float):
	if !_cover_instance:
		return

	_cover_instance.start_uncover(sec)
	await _cover_instance.wait_cover()
	_cover_instance.queue_free()

## 非同期でシーンの読み込みを開始する。
## [param scene_pathes] 非同期に読み込むシーンパスの配列
func async_load_scenes(scene_pathes: Array[String]):
	for _path in scene_pathes:
		# すでに読み込み中なら処理しない
		if _async_load_scene_pathes.has(_path):
			continue
		
		# 読み込み開始
		if ResourceLoader.load_threaded_request(_path) != Error.OK:
			push_error("Load Error: "+_path)
			return
		
		_async_load_scene_pathes.append(_path)

## 画面を覆う処理の完了を待つ。
func wait_cover_finished():
	if _cover_instance:
		await _cover_instance.wait_cover()

## シーンの非同期読み込みをはじめたあとに呼び出して、処理の完了を待つ。
## 画面を覆って、シーンを解放したあとにシーンの再読み込みをしたい場合は
## シーンパスを配列で渡す。
## 読み込みが完了したらcovered_loaded_unloadedをemitしてシーンの初期化へ処理を移す。[br]
## [param add_load_scenes] シーンの解放後に読み込みなおすシーンのパス。無い場合は省略
func wait_and_init_scenes(add_load_scenes: Array[String] = []):
	## 画面覆い完了待ち
	await SceneChanger.wait_cover_finished()

	# TODO 進捗シーンを表示

	# シーンの解放処理
	release_scenes.emit()
	
	# 再読み込みシーン
	async_load_scenes(add_load_scenes)

	# 非同期読み込み待ち
	await wait_async_scenes_loaded()

	# 登録された処理を実行
	await get_tree().process_frame
	covered_loaded_unloaded.emit()

## 非同期読み込みしているシーンの読み込みが完了するのを待つ。
func wait_async_scenes_loaded():
	# 読み込み完了待ち
	var loaded_scenes = Array()
	for path in _async_load_scene_pathes:
		var status = ResourceLoader.load_threaded_get_status(path)

		while status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
			status = ResourceLoader.load_threaded_get_status(path)

		# エラー
		if status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			push_error("wait_async_scenes_loaded error:"+path)
			return
		
		# 読み込み完了
		loaded_scenes.append(ResourceLoader.load_threaded_get(path))
	
	# シーンの作成と子ノード		
	for scene in loaded_scenes:
		var scene_instance = scene.instantiate()
		get_tree().root.add_child(scene_instance)
		
	# パスを解放
	_async_load_scene_pathes.clear()
