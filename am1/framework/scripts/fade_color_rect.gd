class_name Fade
extends ColorRect

## Fade処理用クラス

## 読み込みと同時に消す
func _ready():
	color.a = 0
	
