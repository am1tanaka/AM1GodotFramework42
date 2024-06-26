# 起動とシーン切り替え

## 起動のさせかた

メインシーンに`Boot`を設定して、Bootシーンから起動するようにします。Bootシーンを開いて、必要な情報をインスペクターに設定します。

- Cover Color
  - 起動時に画面を塗りつぶす色です
- Cover Scene Path
  - 画面を覆う処理をするシーンのパスです。デフォルトでは`res://am1/framework/scenes/fade.tscn`が設定されています。起動時の演出を変えたい場合はカスタムのシーンと処理を作成して、ここに設定します
- Load Scenes
  - 最初の起動で読み込むシーンを指定します
  - タイトルのように複数のシーンから移行するときに使い回せるようにResourceを継承した配列になっています。必要に応じて設定を保存すれば他のシーンで利用できます
  - デフォルトでは、すでに読み込み済みのシーンがあったら新規に読み込まずにもとのシーンをそのまま残します
  - リトライ時などの読み込み済みのシーンを新規に読み込み直す場合は、配列のis_reload_when_existsにチェックを入れます
  

## シーン状態の切り替え方

シーン状態を切り替える処理は2ステップで実行します。

1. 元のシーン状態で、画面を覆う処理の読み込みと開始、必要なシーンをSceneChangerに渡してシーン状態の切り替えを開始します
2. 次のシーンの_readyでSceneChangerに初期化処理を渡して、画面が隠れたあとにコールバックさせて、シーンの初期化や画面を表示する処理を実行します

### シーン状態の切り替えをはじめる処理
1つめの処理の例を2つ示します。以下はノードのインスペクターで必要なシーンなどを設定するスクリプトです。

```python
## 画面を覆うシーンの色
@export var cover_color := Color.BLACK

## 画面を覆うシーンのパス
@export_file("*.tscn") var _cover_scene_path

## 最初のシーンを読み込むスクリプト
@export var _load_scenes: LoadScenes

func _change_next_scene():
	## 画面覆い開始
	var cover = SceneChanger.load_cover(_cover_scene_path) as ScreenCover
  cover.start_cover(cover_color, 0)

	## シーン読み込み開始
	SceneChanger.change_scenes_and_wait_covered(_load_scenes)
```

シーンリストを保存済みの場合は以下のようなコードにします。

```python
@export_file("*.tres") var _scenes_resource
@export_file("*.tscn") var _cover_scene_path

func _change_title():
	## 画面覆い開始
	var cover = SceneChanger.load_cover(_cover_scene_path) as ScreenCover
	cover.start_cover(Color.BLACK, 1.0)

	## シーン読み込み開始
	var scenes = load(_scenes_resource)
	SceneChanger.change_scenes_and_wait_covered(scenes)
```

### 切り替えたシーンの初期化と開始

シーン状態の初期化や画面の覆いを外す処理は、シーンが読み込まれたときに初期化メソッドをSceneChangerに登録することで実行します。

```python
func _ready():
	SceneChanger.set_init_scene_method(_init_scene)

## シーンの初期化と開始
func _init_scene():
	await SceneChanger.uncover(1.0)
	GameState.control_on()
	_bgm_player.play_bgm()
```

シーンの読み込みと画面を覆う処理が完了したら、登録した_init_scene()がSceneChangerから呼び出されます。
_init_scene()では、画面の覆いを解除やその他の必要な初期化を実行して、該当するシーン状態を開始します。




## 構成

- 常時シーン
  - SceneChanger
	- SceneChangerクラスがアタッチされている。シーン切り替えの処理を管轄
  - シーン切り替えクラス
	- SceneChanger.change_scene(シーンパス)で生成するシーン切り替え処理
	- アタッチしたスクリプトの_enter_tree()に次のシーンを読み込む
	- start_title.gdやcold_start_game.gdなど
- シーン管理クラス
  - メインのシーンのルートにアタッチするスクリプト
  - _readyで初期化メソッドをSceneChanger.set_init_scene_method()で登録
  - シーンの初期化は、画面が隠れてシーンの読み込みが完了したら呼ばれる
  - シーンの初期化処理のときに、解放する関数を登録
  - シーンが切り替わるときに、不要なシーンを削除する解放処理を持つ
- シーンの切り替えクラス
  - SceneChanger.change_scene(スクリプトのパス)で生成して開始
  - _enter_tree()にシーン切り替え処理を実装
  - 次に必要なシーンの非同期読み込み開始やフェードアウトなどの演出を処理
  - 画面を覆って、シーンの切り替え処理を完了したらシーン管理クラスの_readyから登録された初期化処理を呼び出して役目終了

## サンプルコード

### シーンの管理クラス
デモのタイトルシーンの初期化クラスです。これが最小構成です。

```
extends Node

## タイトル制御クラス

func _ready():
	SceneChanger.set_init_scene_method(init_title)

## タイトルシーンの初期化
func init_title():
	SceneChanger.release_scenes.connect(release_title)
	await SceneChanger.uncover(1.0)
	GameState.control_on()

## 解放
func release_title():
	queue_free()
```

### シーン切り替えクラス
シーンの切り替えシーケンスを実行するクラスです。これをNodeで作成したシーンにアタッチして、SceneChanger.change_scene()にパスを渡すことでシーンの切り替えを開始します。

```
extends Node

func _enter_tree():
	## 画面覆い開始
	var fade = SceneChanger.load_cover("res://am1/framework/scenes/fade.tscn") as ScreenCover	
	fade.start_cover(Color(0.0, 0.0, 0.0, 0.0), 1.0)

	## シーン読み込み開始
	SceneChanger.async_load_scenes(["res://am1/framework/demo/scenes/game.tscn"])

	## シーンの読み込み完了を待って、シーンの初期化メソッドを呼び出す
	SceneChanger.wait_and_init_scenes()

	## 切り替えが終わったら解放
	queue_free()
```

レベルなどの再読み込みが必要な場合は、`SceneChanger.wait_and_init_scenes()`に再読み込みをするシーンのパスの配列を引数で渡します。

## シーンの継続
- 特定のシーンをほかのシーンに引き継ぐ場合、SceneChangerノードにシーンを移動させて、切り替え終わったら新しいメインシーンに移動させる
- SceneChangerノードの下に目的のシーンがなければ、

- タイトルとゲームで同じstageシーンを使いたい場合
  - シーンにあらかじめstageを入れてしまうと多重読み込みになるので不可
  - 初回起動時にstageを読み込む必要がある
  - ゲームからタイトルに戻るときは、stageがあることを確認して、

### 起動時
- titleとstageを読み込みたい場合


## クラス
- SceneChanger
  - Autoloadに登録して自動生成するスクリプト
  - 配下にsub_scene_changerノードを持ち、そこに画面を覆う処理などを所属させます
  - change_scene(切り替えシーンのパス)
	- 操作を禁止したのち、渡されたパスのシーンを非同期読み込みします
  - set_init_scene_method(シーンの初期化メソッド)
	- シーンの_readyから呼び出して初期化メソッドを登録します
	- 初回起動のときは即時、初期化メソッドを呼び出します
	- 二回目以降のときはシグナルに登録して、初期化emitで実行します
  - load_cover(画面を覆うシーンのパス)
	- 画面を覆う演出シーンを非同期で読み込んで制御クラスのインスタンスを返します
  - uncover(秒数)
	- 画面の覆いを指定秒数で解除します
	- awaitで完了を待ちます
  - async_load_scenes(読み込むシーンパスの配列)
	- 文字列の配列で指定したシーンを非同期読み込み開始します
  - wait_cover_finished
	- 画面を覆う処理の完了をawaitで待ちます
  - wait_and_init_scenes
	- 再読み込みがないシーン向けの切り替え処理
	- 画面の覆いを待って、シーンの解放、非同期読み込み待ち、シーンの生成、1フレーム待ってから登録された初期化処理の呼び出しをまとめて実行
  - wait_scenes_async_loaded
	- 非同期読み込み中の全てのシーンの読み込み完了を待って、生成してルートの子にする処理
	- awaitで待つ
	- 再読み込みがある初期化のときに利用

次のシーンの読み込みと

必要なシーンの非同期読み込み
シーンの切り替えを跨いで処理する


---

## 要件
- 操作や判定を停止
- 画面を隠す処理中に次の必要なシーンを非同期読み込み
- 画面を隠す画像をシーンをまたいで維持
- 画面が隠れたときの処理
  - 必要なシーンをすべて読み込む
  - 不要になったシーンを解放
  - すべてのシーンが揃ったら初期化を呼び出す
  - 読み込み状況の表示
- BGMの再生を継続
- 画面の覆いを外す
- 操作の復帰

## シーン遷移

### 必要なもの
- SceneChangerクラス
  - Autoloadに登録して永続
  - SceneChanger.set_init_scene_method(メソッド)
    - covered_loaded_unloadedシグナルに登録するシーンの初期化用メソッド
  - SceneChanger.change_scene(シーンの切り替えを開始するシーンのパス)
    - 渡されたパスを生成してSceneChangerの子供にして処理
- Autoload、あるいは、切り替え元シーン
  - change_sceneの呼び出し
  - release_scenesシグナルに登録するシーンの解放用メソッド
- 新しく読み込むシーン
  - set_init_scene_methodに渡すメソッド
- シーンの切り替えを開始するためのスクリプトを持ったシーン
  - 画面を覆う処理の登録や必要なシーンの読み込み開始、画面を覆う処理の開始、非同期読み込みが完了するのを待って、release_scenesとcovered_loaded_unloadedシグナルをemit

### Autoload
- SceneChangerノードを生成して子ノードにする
- GameStateでゲーム状態の読み込み
- _readyで以下を実行
  - 最初の画面を隠す処理を登録
- シーンからset_init_scene_method(初期化メソッド)を受け取る
  - 操作を禁止
  - はじめて
	- シーンの読み込みは不要。受け取ったcovered_loaded_unloadedを即時emit
  - 2回目以降
	- 受け取った処理をcovered_loaded_unloadedにconnect。呼び出しはシーンの切り替え処理中に実行

### シーンの起動
- GodotがAutoloadののち、最初のシーンを起動
- シーンスクリプトの_ready
  - SceneChangerのメソッドにcovered_loaded_unloadedシグナルに初期化処理を渡す
- covered_loaded_unloadedシグナルに登録したタイトル初期化処理
  - release_scenesシグナルを解放して、現在のシーンの解放処理をconnect
  - 再読み込みなどのシーンを追加で非同期読み込み登録
  - 読み込みプログレスを表示
  - 読み込みの完了をawait
  - シーンの初期化を実行
    - タイトルならUIを現在の状態にあわせて設定(各UIに実装)
  - 登録されているフェードインを開始
  - 操作を可能にしてシーン開始
  - SceneChangerに登録した画面の覆いシーンを削除
  - 自分を削除

### タイトルからゲームを開始
- タイトルのシーンから次のデータをSceneChanger.change_sceneに渡して呼び出す
　- 初期化処理を実行するシーン
- SceneChanger.change_scene()で以下を実行
  - 操作を禁止
  - 次のシーンに必要なシーンをSceneChanger.load_threadedに配列を渡して非同期読み込み開始
  - シーン切り替えシーンを読み込んで子供にする。インスタンスを保存
  - フェード開始
  - フェードの完了と非同期読み込みの完了を待つ
  - フェードアウトの完了を待つ
  - release_scenesをemit
  - 非同期読み込みの完了を待つ
  - covered_loaded_unloadedをemit
  - ここから先は次のシーンが登録したシグナルに処理を引き継ぐ


### 他のシーンへ
- 操作を禁止
- SceneChangerに以下を渡すメソッドを呼び出す
  - 以下を型定義
    - 画面を覆うシーンのPackedScene
    - 非同期で読み込むシーンの配列
    - 解放するシーンの配列
    - 同期読み込みするシーンの配列
  - 以上を記録して処理を開始
- シーンの初期化はシーンの_readyで登録

## 開発項目

### SceneChangerクラス(scene_changer.gd)
- シーン切り替えに関する処理のファサード
- Autoloadに登録
- シーン切り替えを実行するのに必要な機能と場所を提供
- シーンの非同期読み込みと解放の管理
- シーン切り替え処理を持ったノードを受け取って処理開始
  - 処理を禁じる
  - 切り替え処理ノードをawaitで非同期読み込み
  - 切り替え処理ノードをSceneChangerの子供に移動
  - 切り替えシーケンスを呼び出して終わり
- 画面を覆うシーンを受け取って、配下にして、進捗を確認
- covered_loaded_unloadedシグナルを定義。画面が隠されて、非同期読み込みや解放がすべて完了したらemit
- 画面の表示開始
- uncoveredに登録する処理を受け取って登録

### SceneChangeData extends RefCounted

以下を保持して、SceneChangerに受け渡すためのクラス。

- 画面を覆うシーンのパック
- 非同期で読み込むシーンの配列
- 解放するシーンの配列
- 同期読み込みするシーンの配列


### SceneChangeProgress
- SceneChangerの子ノード
- 読み込み中のインジケーターを表示

### StartCover
- SceneChangerの子ノードに作成するColorRect
- とりあえず画面を隠す。タイトルのフェードと同じ色にする
- 最初のシーンが起動したら消す

### 画面を覆うためのシーン
- 隠す処理と表示処理を持つ
- シーン切り替え時に実行
- 隠しきったときのシグナルcoveredと表示しきったときのシグナルuncoveredを用意
- シーンの切り替わり時に消えないように実行時はSceneChangerの子にする

### シーン構成
- タイトルシーン
- タイトル初期化シーン
- ゲームシーン
- ゲーム初期化シーン

## 技術
- シーンの切り替え
  - [SceneTree](https://docs.godotengine.org/ja/4.x/classes/class_scenetree.html#class-scenetree-method-change-scene-to-packed)
- [Core Tech. シーン切り替え](https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html)
- [バックグラウンド読み込み](https://docs.godotengine.org/ja/4.x/tutorials/io/background_loading.html)
- [非同期](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines)

## 非同期について
- `await`キーワードを使う
- awaitのうしろにシグナルか関数呼び出しをするとそのメソッドはそこで処理を中断して処理を呼び出しもとに返す。シグナルか戻り値が戻ったらメソッドがその場から再開する
- await呼び出しの戻り値を受け取るように書くと、戻り値が返ってくるまでそのメソッドも中断する
- awaitを内部で使っているメソッドの戻り値を受け取る場合、呼び出しにawaitを付けないとエラーになる
- 非同期を開始するだけなら、awaitを付けず、戻り値を受け取らないように呼び出す
- 1フレーム待つ `await get_tree().process_frame`
  - `await Engine.get_main_loop().process_frame`
