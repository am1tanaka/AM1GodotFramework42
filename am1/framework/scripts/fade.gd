class_name Fade
extends ScreenCover

## Fade処理用クラス

## キャッシュ
@onready var color_rect : ColorRect = $CanvasLayer/ColorRect
var tween: Tween

## 読み込みと同時に消す
func _ready():
	color_rect.color.a = 0

## フェードアウト実行
## color フェードの色
## sec フェード秒数
func start_cover(color: Color, sec: float):
	if tween:
		tween.kill()
	
	# 瞬時に画面を覆う
	if 	is_zero_approx(sec):
		color.a = 1.0
		color_rect.color = color
		return

	# フェードアウト
	color.a = 0.0
	color_rect.color = color

	var final_color = color
	final_color.a = 1
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(color_rect, "color", final_color, sec)

## Tweenの完了をawaitで待つ
func wait_tween():
	if tween:
		await tween.finished

## フェードイン実行
## sec フェード秒数
func start_uncover(sec: float):
	if tween:
		tween.kill()

	if is_zero_approx(sec):
		color_rect.color.a = 0
		return

	var final_color = color_rect.color
	final_color.a = 0
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(color_rect, "color", final_color, sec)

## このシーンを消します
func release():
	if tween:
		tween.kill()
	queue_free()
