extends Node

## シーンの遷移を管理するクラス。[br]
## 最初に起動するシーンの_ready関数でset_init_scene_method()に初期化メソッドを渡して呼び出す。
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
var is_booting: bool:
	get:
		return _is_booting
var _is_booting: bool = true

## 非同期読み込み中のシーン名
var _async_load_scene_pathes: Array[String] = []

## 必要なシーンの配列
var _need_scene_paths: Array[String] = []

## リロード対象のシーン名の配列
var _reload_scene_paths: Array[String] = []

## 読み込んだシーンのパス
var _loaded_scene_paths: Array[String] = []

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

	if is_booting:
		_is_booting = false
		init_method.call()
	else:
		covered_loaded_unloaded.connect(init_method)

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
	await _cover_instance.wait_cover()
	_cover_instance.queue_free()

## 画面を覆う処理を開始してから呼び出す。
func change_scenes_and_wait_covered(scenes: LoadScenes):
	# 画面を覆うために1フレーム待つ
	await get_tree().process_frame

	# 渡されたシーンのうち、読み込まれていないものを非同期読み込み開始
	async_load_scenes_with_reload(scenes)

	# 画面が覆われるのを待つ
	await wait_cover_finished()

	# 不要なシーンとリロード予定のシーンを解放する
	unload_unnecessary_scenes(scenes)

	# リロードシーンを読み込む
	async_load_scenes(_reload_scene_paths)

	# 非同期読み込み待ち
	await wait_async_scenes_loaded()

	# 登録された処理を実行
	await get_tree().process_frame

	# 切り替え処理中に受け取った初期化処理を呼び出す
	covered_loaded_unloaded.emit()

## 引数で受け取ったシーンに含まれないシーンと、含まれていてリロードが指定されているシーンを解放する。
func unload_unnecessary_scenes(scenes: LoadScenes):
	var loaded_paths = _get_root_scenes()
	var keys = loaded_paths.keys()

	# 必要ないものを消す
	for key in keys:
		for scene in scenes.scenes:
			if !scene.scene_path == key:
				loaded_paths[key].queue_free()
	
	# リロード対象を消す
	for sc in scenes.scenes:
		if sc.is_reload_when_exists && keys.has(sc.scene_path):
			loaded_paths[sc.scene_path].queue_free()

## ルートにあるシーンのファイルパスを配列にして返す。
func _get_root_scenes() -> Dictionary:
	var nodes = get_tree().root.get_children()
	var result := Dictionary()
	for node in nodes:
		var file_path = node.scene_file_path
		if !file_path.is_empty():
			result[file_path] = node
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
	if !_loaded_scene_paths.has(sc.scene_path):
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

## 指定のシーンを解放する。[br]
## [param scene_names] 削除するシーン名を配列で指定
func free_scenes(scene_names: Array[String]):
	var nodes = get_tree().root.get_children()
	for node in nodes:
		for scene_name in scene_names:
			if node.name == scene_name:
				node.queue_free()
				break


