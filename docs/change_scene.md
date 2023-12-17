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

### Autoload
- SceneChangerノード。画面を隠す
- ゲーム状態の読み込み

### シーンの起動
- シーンスクリプトの_ready
  - SceneChangerに切り替えシーンを渡して処理開始
	- SceneChanger.change_scene()
      - 操作を禁じる
	  - 受け取った初期化処理を開始
- タイトル初期化処理
  - 隠している間の初期化。タイトルならUIを現在の状態にあわせて設定(各UIに実装)
  - 画面の覆いが外れたシグナルを設定
  - 画面の覆いを解除する演出開始
  - SceneChangerに保存されていた画面の覆いを削除
- 画面の覆いが外れた
  - 操作を開始

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
