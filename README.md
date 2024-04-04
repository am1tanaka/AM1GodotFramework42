# Godot 4.2.X用フレームワーク

自家製フレームワーク。

## 機能
- シーンの非同期読み込みに対応した状態切り替え
- BGMと効果音のボリューム制御と保存

## セットアップ
- 自動読み込みに以下を追加
  - SceneChanger res://am1/framework/scripts/system/scene_changer.gd
  - GameState res://am1/framework/scripts/system/game_sate.gd
  - SystemSePlayer res://am1/framework/scripts/audio/system_se_player.gd
- プロジェクト>プロジェクト設定を開く
  - オーディオのパスを選択
  - デフォルトのパスレイアウトにam1/audio_volume/settings/audio_bus_layout.tresを設定

### demoを実行するための設定

- インプットマップに`Accept`と`GameOver`を追加する。割り当ては任意。Acceptをクリックとスペース、GameOverを`O`など


## 予定

https://github.com/users/am1tanaka/projects/6/views/1


## 使用アセット
- フォント
  - The M+ FONTS Project Authors (https://github.com/coz-m/MPLUS_FONTS)
- BGMと効果音
  - kenney.nl (https://kenney.nl)

## ライセンス

MIT License

