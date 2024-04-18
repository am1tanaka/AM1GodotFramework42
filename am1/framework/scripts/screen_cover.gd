class_name ScreenCover
extends Node

## 画面を覆う処理のベースクラス

enum STATE {
	NONE,
	COVERING,
	COVERED,
	UNCOVERING
}

## 現在の状態
func get_current_state() -> STATE:
	return _current_state
var _current_state := STATE.NONE

## start_cover()
## 画面を覆う処理を開始
## 引数は自由

## start_uncover(秒数)
## 画面の覆いの解除を開始

## wait_cover
## 覆いや表示の完了を待つawait

