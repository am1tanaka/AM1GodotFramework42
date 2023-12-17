extends Node

## ゲーム全体の状態を管理するクラス

## 操作禁止に変わったシグナル
signal control_off_changed

## 操作可に切り替わったときのシグナル
signal control_on_changed

var can_control: bool = false

## 操作を許可する
func control_on():
	if !can_control:
		can_control = true
		control_on_changed.emit()

## 操作を禁じる
func control_off():
	if can_control:
		can_control = false
		control_off_changed.emit()

