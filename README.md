# Godot 4.2.X用フレームワーク

自家製フレームワーク。

## 機能
- シーンの非同期読み込みに対応した状態切り替え
- BGMと効果音のボリューム制御と保存

## セットアップ

本フレームを他のプロジェクトに追加する手順は以下の通りです。

- 本リポジトリの`am1`フォルダーを利用したいプロジェクトにコピーします
- デモを動かす場合は`kenney`と`mplus`フォルダーもコピーします
- `am1/demo`フォルダーから利用できそうなファイルをプロジェクトへ移動します
- 自動読み込みに以下を追加します
  - SceneChanger res://am1/framework/scripts/system/scene_changer.gd
  - GameState res://am1/framework/scripts/system/game_sate.gd
  - SystemSePlayer res://am1/framework/scripts/audio/system_se_player.gd
- プロジェクト>プロジェクト設定を開きます
  - メインシーンをBootシーンにします
  - オーディオのパスを選択します
  - デフォルトのパスレイアウトにam1/audio_volume/settings/audio_bus_layout.tresを設定します

### demoを実行するための設定

- インプットマップに`Accept`と`GameOver`を追加する。割り当ては任意。Acceptをクリックとスペース、GameOverを`O`など


## ドキュメント
- [起動とシーンの切り替え](docs/boot_and_change_scene.md)

## 予定

https://github.com/users/am1tanaka/projects/6/views/1


## 使用アセット
- フォント
  - The M+ FONTS Project Authors (https://github.com/coz-m/MPLUS_FONTS)
- BGMと効果音
  - kenney.nl (https://kenney.nl)

## ライセンス

MIT License

