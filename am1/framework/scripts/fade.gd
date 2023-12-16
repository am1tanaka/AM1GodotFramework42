class_name Fade
extends Node

## Fade処理用クラス

## シグナル
signal _fade_out
signal _fade_in

## キャッシュ
@onready var colorRect : ColorRect = $CanvasLayer/ColorRect
@onready var tween = create_tween()

## 読み込みと同時に消す
func _ready():
	colorRect.color.a = 0
	start_fade_out(1.0, test_start_fade_in)

func start_fade_out(sec: float, done):
	
	print("start_fade_out")
	_fade_out.connect(done)

func start_fade_in(sec: float, done):
	print("start_fade_in")

func test_start_fade_in():
	print("test_start_fade_in")

