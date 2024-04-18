extends Node

## シーンの遷移を管理するクラス。[br]
## 起動[br]
## 移動用のシーンを作成して、_enter_tree()に画面を覆うシーンとシーンの読み込み開始処理を呼び出す。
## @tutorial(起動シーンのスクリプト):	https://github.com/am1tanaka/AM1GodotFramework42/blob/master/am1/framework/demo/scripts/boot.gd
## [br]
## シーンの切り替え[br]
## 切り替え元のシーンでSceneChanger.load_cover()で画面を覆うシーンの読み込みと開始をして、
## SceneChanger.change_scene_and_wait_cover()を実行する。
## [br]
## シーンの初期化[br]
## _ready関数でset_init_scene_method()を呼び出して初期化メソッドを登録する。
## 登録した初期化メソッドは画面を覆う処理とシーンの入れ替えが完了したら呼び出される。
## [br]
## set_init_scene_method()に渡す初期化メソッドの例は以下の通り。[br]
## @tutorial(シーンの管理クラス):      https://datgm23.github.io/AM1GodotFramework42/docs/examples/scene_manage_class.md
## @tutorial(シーンを切り替えるクラス): https://datgm23.github.io/AM1GodotFramework42/docs/examples/change_scene_sequence.md

## 画面を覆って、読み込みや解放が完了したら呼び出すシグナル
signal covered_loaded_unloaded

## シーンを解放するときに実行するシグナル
signal release_scenes

## スクリーンを覆う処理のインスタンス
var _cover_instance: ScreenCover

## 最初の起動フラグ
func get_is_booting() -> bool:
	return _is_booting
var _is_booting: bool = true

## 非同期読み込み中のシーン名
var _async_load_scene_pathes: Array[String] = []

## SceneChangerで読み込んだシーンのパスとインスタンス
var _loaded_scene_paths_and_instances: Dictionary

## 必要なシーンの配列
var _need_scene_paths: Array[String] = []

## リロード対象のシーン名の配列
var _reload_scene_paths: Array[String] = []

## 指定のパスのシーンを読み込んで、子ノードにしてインスタンスを返す。[br]
## [param cover_path] 画面を覆うシーンのパス
func load_cover(cover_path) -> ScreenCover:
	if !cover_path:
		return null
	if ResourceLoader.load_threaded_request(cover_path) != Error.OK:
		push_error("load_cover error:"+cover_path)
		return null
	
	var _cover_node = ResourceLoader.load_threaded_get(cover_path)
	_cover_instance = _cover_node.instantiate() as ScreenCover
	add_child(_cover_instance)
	return _cover_instance

## 画面の覆いを解除する。awaitで解除を待つことができる。
## [param sec] 画面の覆いを解除する秒数
func uncover(sec: float):
	if !_cover_instance:
		return

	_cover_instance.start_uncover(sec)
	await _cover_instance.wait_uncover()
	_cover_instance.queue_free()

## 画面を覆う処理を開始してから呼び出す。
func change_scenes_and_wait_covered(scenes: LoadScenes):
	# 操作禁止
	GameState.control_off()

	# 画面を覆うために1フレーム待つ
	await get_tree().process_frame

	# 渡されたシーンのうち、読み込まれていないものを非同期読み込み開始
	async_load_scenes_with_reload(scenes)

	# 画面が覆われるのを待つ
	await wait_cover_finished()

	# 不要なシーンとリロード予定のシーンを解放する
	_unload_unnecessary_scenes(scenes)

	# リロードシーンを読み込む
	async_load_scenes(_reload_scene_paths)

	# 非同期読み込み待ち
	await wait_async_scenes_loaded()
	_update_loaded_scenes_data(scenes.scenes)

	# 1フレーム待ってから切り替え処理中に受け取った初期化処理を呼び出す
	await get_tree().process_frame
	covered_loaded_unloaded.emit()
	_disconnect_covered_loaded_unloaded()

## 読み込み指定したシーンのパスとインスタンスを記録する。
func _update_loaded_scenes_data(scenes: Array[LoadSceneData]):
	_loaded_scene_paths_and_instances.clear()
	var root_scenes = get_tree().root.get_children()

	for scene in scenes:
		for root_scene in root_scenes:
			if root_scene.scene_file_path == scene.scene_path:
				_loaded_scene_paths_and_instances[scene.scene_path] = root_scene
				break

## メインシーンの_readyから呼び出される。
## 渡されたメソッドをcovered_laoded_uncoveredにconnectして、
## 次のシーンの読み込みや画面を覆う演出を終えてからemitする。[br]
## [param init_method] 画面を覆って非同期読み込みが完了したら呼び出す初期化処理[br]
func set_init_scene_method(init_method: Callable):
	GameState.control_off()
	covered_loaded_unloaded.connect(init_method)
	_is_booting = false

## 引数で受け取ったシーンに含まれないシーンと、含まれていてリロードが指定されているシーンを解放する。
func _unload_unnecessary_scenes(scenes: LoadScenes):
	var keys = _loaded_scene_paths_and_instances.keys()

	# 必要ないものを消す
	for key in keys:
		var need := false
		for need_scene in scenes.scenes:
			if need_scene.scene_path == key:
				need = true
				break
		if !need:
			var node = _loaded_scene_paths_and_instances[key]
			_loaded_scene_paths_and_instances.erase(key)
			node.queue_free()
	
	# リロード対象を消す
	for sc in scenes.scenes:
		if sc.is_reload_when_exists && keys.has(sc.scene_path):
			var node = _loaded_scene_paths_and_instances[sc.scene_path]
			_loaded_scene_paths_and_instances.erase(sc.scene_path)
			node.queue_free()

## ルートにあるシーンのパスとノードをディクショナリで返す。
func _get_root_scene_paths_and_nodes() -> Dictionary:
	var nodes = get_tree().root.get_children()
	var result := Dictionary()
	for node in nodes:
		var file_path = node.scene_file_path
		if !file_path.is_empty():
			result[file_path] = node
	return result

## ルートにあるシーンのファイルパスを配列で返す。
func _get_root_scene_paths() -> Array[String]:
	var nodes = get_tree().root.get_children()
	var result : Array[String] = []
	for node in nodes:
		var file_path = node.scene_file_path
		if !file_path.is_empty():
			result.append(file_path)
	return result

## 非同期でシーンの読み込みを開始する。
## シーンが読み込み済みなら、リロードするかどうかを引数で確認する。
## リロードするシーンなら後の処理で解放と読み込みをするために配列に取っておく。
## [param scene_pathes] 非同期に読み込むシーンパスの配列
func async_load_scenes_with_reload(scenes: LoadScenes):
	_need_scene_paths.clear()
	_reload_scene_paths.clear()
	scenes.scenes.all(_listup_scene_path)
	
	async_load_scenes(_need_scene_paths)

## シーンを読み込み状況に応じて読み込みとリロードの配列にリストアップする
func _listup_scene_path(sc):
	var root_paths = _get_root_scene_paths()
	
	if !root_paths.has(sc.scene_path):
		# 読み込まれていなければ必要なシーンにリストアップ
		_need_scene_paths.append(sc.scene_path)
	elif sc.is_reload_when_exists:
		# 読み込まれていて、かつ、リロード対象ならリロードにリストアップ
		_reload_scene_paths.append(sc.scene_path)

	return true

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
	if _cover_instance != null:
		await _cover_instance.wait_cover()

## 画面の覆いが外れるのを待つ。
func wait_uncover_finished():
	if _cover_instance != null:
		await _cover_instance.wait_uncover()

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
	_disconnect_covered_loaded_unloaded()

## カバー完了後に実行するシグナルを解放する。
func _disconnect_covered_loaded_unloaded():
	var connections = covered_loaded_unloaded.get_connections()
	for conn in connections:
		if conn.callable != null:
			covered_loaded_unloaded.disconnect(conn.callable)

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
			push_error("wait_async_scenes_loaded error : %s : %s" % [path, status])
			return
		
		# 読み込み完了
		loaded_scenes.append(ResourceLoader.load_threaded_get(path))
	
	# シーンの作成と子ノード		
	for scene in loaded_scenes:
		var scene_instance = scene.instantiate()
		get_tree().root.add_child(scene_instance)

	# パスを解放
	_async_load_scene_pathes.clear()

## 指定のシーンを解放する。[br]
## [param scene_names] 削除するシーンのパスを配列で指定
func free_scenes(scene_paths: Array[String]):
	var nodes = get_tree().root.get_children()
	for node in nodes:
		for scene_path in scene_paths:
			if node.scene_file_path == scene_path:
				_loaded_scene_paths_and_instances.erase(node.scene_file_path)
				node.queue_free()
				break

# 指定のシーンがすべて開くまで待つ
func wait_scene_loaded_all(scene_names: Array[String]):
	while !SceneChanger.is_scene_loaded_all(scene_names):
		await get_tree().process_frame

# 指定のシーンがすべて閉じるまで待つ
func wait_scene_closed_all(scene_names: Array[String]):
	# ひとつも開いていない状態になるまで待つ
	while !SceneChanger.is_scene_closed_all(scene_names):
		await get_tree().process_frame

## 配列でシーン名を受け取って、すべてのシーンが読み込まれていたらtrueを返す。
func is_scene_loaded_all(scene_names: Array[String]) -> bool:
	return scene_names.all(is_scene_loaded)

## 配列でシーン名を受け取って、すべてのシーンがなければtrueを返す。
func is_scene_closed_all(scene_names: Array[String]) -> bool:
	return !scene_names.any(is_scene_loaded)

## 指定のシーン名が読み込まれていたらtrueを返す。
func is_scene_loaded(scene: String) -> bool:
	var root_scenes = get_tree().root.get_children()
	for root_scene in root_scenes:
		if scene == root_scene.name:
			return true
	return false
