extends Node

## ゲームオーバーシーンの管理クラス

@onready var _tween = create_tween()
@onready var _color_rect: ColorRect = $CanvasLayer/ColorRect as ColorRect
@onready var _game_over_label: Label = $CanvasLayer/GameOver as Label

const _fade_in_seconds = 0.5

# 初期化
func _ready():
	GameState.control_off()
	
	# 初期値
	var final_color_rect = _color_rect.color
	_color_rect.color.a = 0

	var final_text_color = _game_over_label.modulate
	_game_over_label.modulate.a = 0

	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	_tween.tween_property(_color_rect, "color", final_color_rect, _fade_in_seconds)
	_tween.tween_property(_game_over_label, "modulate", final_text_color, _fade_in_seconds)
	_tween.finished.connect(GameState.control_on)

## ゲームオーバーの更新処理
func _process(_delta):
	if !GameState.can_control:
		return

	if Input.is_action_just_pressed("Accept"):
		SceneChanger.change_scene("res://am1/framework/demo/scripts/start_title.gd")
