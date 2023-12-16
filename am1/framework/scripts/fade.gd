class_name Fade
extends Node

## Fade処理用クラス

@onready var colorRect : ColorRect = $CanvasLayer/ColorRect

## 読み込みと同時に消す
func _ready():
	colorRect.color.a = 0
	
## テストコード
func _process(delta):
	pass
	# start fade in
	# start fade out
