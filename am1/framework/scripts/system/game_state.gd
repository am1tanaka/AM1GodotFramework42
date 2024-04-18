extends Node

## ゲーム全体の状態を管理するクラス

## 操作禁止に変わったシグナル
signal control_off_changed

## 操作可に切り替わったときのシグナル
signal control_on_changed

var _can_control := false
## 操作可能なとき、true
func can_control() -> bool:
	return _can_control

var _is_debug := false
## デバッグモード
func is_debug() -> bool:
	return _is_debug

var _bgm_player: AudioPlayer
## 再生中のBgmPlayer
func get_bgm_player() -> AudioPlayer:
	return _bgm_player

## 操作を許可する
func control_on():
	if !can_control():
		_can_control = true
		control_on_changed.emit()

## 操作を禁じる
func control_off():
	if can_control():
		_can_control = false
		control_off_changed.emit()

## デバッグモードを設定する。
func set_debug(flag: bool):
	_is_debug = flag

## 指定のプレイヤーインスタンスを記録する。
func set_bgm_player(player: AudioPlayer):
	_bgm_player = player
