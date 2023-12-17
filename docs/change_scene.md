# シーン切り替え

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
- シーンからset_init_scene(初期化シーンパス)を受け取る
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
