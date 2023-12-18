# シーンの管理クラス

## 初期化の処理

- _ready
  - 初期化処理を実行、あるいはシグナルに登録
- init_title
  - 画面を隠してシーンの読み込みが完了したら実行する処理
  - 解放処理の登録、覆いの解除、操作許可を実行するのが一般的な内容
- release_title
  - この状態向けのシーンを解放

```
extends Node

## タイトル制御クラス

## シーンが開始したら初期化関数を登録
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

