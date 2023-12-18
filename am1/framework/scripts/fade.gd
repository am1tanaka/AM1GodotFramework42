class_name Fade
extends ScreenCover

## 画面をフェードで覆う演出を制御するクラス

## Tweenをキャッシュする変数。
var _tween: Tween

## 塗りつぶしのノードにアタッチされているColorRectクラスのインスタンス。
@onready var _color_rect : ColorRect = $CanvasLayer/ColorRect

## 読み込みと同時に消す。
func _ready():
	_color_rect.color.a = 0

## フェードアウトを開始する。[br]
## [param color] フェードの色[br]
## [param sec] フェード秒数[br]
func start_cover(color: Color, sec: float):
	if _tween:
		_tween.kill()
	
	# 瞬時に画面を覆う
	if 	is_zero_approx(sec):
		color.a = 1.0
		_color_rect.color = color
		return

	# フェードアウト
	color.a = 0.0
	_color_rect.color = color

	var final_color = color
	final_color.a = 1
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_color_rect, "color", final_color, sec)

## 覆う処理をawaitで待つ。[br]
func wait_cover():
	if _tween:
		await _tween.finished

## フェードインを開始する。[br]
## [param sec] フェード秒数
func start_uncover(sec: float):
	if _tween:
		_tween.kill()

	if is_zero_approx(sec):
		_color_rect.color.a = 0
		return

	var final_color = _color_rect.color
	final_color.a = 0
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_color_rect, "color", final_color, sec)

## このシーンを消す。
func release():
	if _tween:
		_tween.kill()
	queue_free()
