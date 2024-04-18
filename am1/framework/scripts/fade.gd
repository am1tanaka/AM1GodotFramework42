class_name Fade
extends ScreenCover

## 画面をフェードで覆う演出を制御するクラス

## Tweenをキャッシュする変数。
var _tween: Tween

## 塗りつぶしのノードにアタッチされているColorRectクラスのインスタンス。
@onready var _color_rect : ColorRect = $CanvasLayer/ColorRect

var _fade_color: Color
var _seconds: float
var _is_requested := false

## 読み込みと同時に消す。
func _ready():
	_color_rect.color.a = 0
	if _is_requested:
		start_cover(_fade_color, _seconds)

## フェードアウトを開始する。[br]
## [param color] フェードの色[br]
## [param sec] フェード秒数[br]
func start_cover(color: Color, sec: float):
	_current_state = STATE.COVERING

	if !_color_rect:
		_fade_color = color
		_seconds = sec
		_is_requested = true
		return
	_is_requested = false
	
	if _tween:
		_tween.kill()
	
	# 瞬時に画面を覆う
	if 	is_zero_approx(sec):
		color.a = 1.0
		_color_rect.color = color
		_current_state = STATE.COVERED
		return

	# フェードアウト
	color.a = 0.0
	_color_rect.color = color

	var final_color = color
	final_color.a = 1
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_color_rect, "color", final_color, sec)
	_tween.finished.connect(func(): _current_state = STATE.COVERED)

## 覆い終わるまでawaitで待つ。
func wait_cover():
	while get_current_state() != STATE.COVERED:
		await get_tree().process_frame

## 覆いが解除されるまでawaitで待つ。
func wait_uncover():
	while get_current_state() != STATE.NONE:
		await get_tree().process_frame

## フェードインを開始する。[br]
## [param sec] フェード秒数
func start_uncover(sec: float):
	_current_state = STATE.UNCOVERING
	
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
	_tween.finished.connect(func(): _current_state = STATE.NONE)

## このシーンを消す。
func release():
	if _tween:
		_tween.kill()
	queue_free()
