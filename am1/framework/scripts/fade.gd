class_name Fade
extends Node

## Fade処理用クラス

## シグナル
signal _fade_out
signal _fade_in

## キャッシュ
@onready var color_rect : ColorRect = $CanvasLayer/ColorRect

## 読み込みと同時に消す
func _ready():
	color_rect.color.a = 0
	start_fade_out(color_rect.color, 1.0, test_start_fade_in)

## フェードアウト実行
## color フェードの色
## sec フェード秒数
## done フェードアウト完了時に呼び出したい関数
func start_fade_out(color: Color, sec: float, done):
	color.a = 0
	color_rect.color = color

	var final_color = color
	final_color.a = 1
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(color_rect, "color", final_color, sec).finished.connect(done)

## フェードイン実行
## sec フェード秒数
## done フェードイン完了時に呼び出したい関数
func start_fade_in(sec: float, done):
	var final_color = color_rect.color
	final_color.a = 0
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(color_rect, "color", final_color, sec).finished.connect(done)

## 動作確認用メソッド
func test_start_fade_in():
	start_fade_in(1.0, test_fade_in_done)

func test_fade_in_done():
	print("フェードイン完了")
