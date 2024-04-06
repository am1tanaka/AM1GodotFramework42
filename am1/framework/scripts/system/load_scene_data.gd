class_name LoadSceneData
extends Resource

## シーンの読み込みデータ

## シーン
@export_file("*.tscn") var scene_path: String

## 読み込み済みのシーンをリロードするときにチェック。チェックがなければ既存のシーンをそのまま使う。
@export var is_reload_when_exists: bool
