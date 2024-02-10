class_name AM1VolumeSlider
extends Node

## ボリュームを制御するスライダー

## バスや保存時の文字列
@export var key_string: String
## ラベルに表示する文字列
@export var label_text: String
## デフォルトの値
@export var default_volume: int

## ボリュームが変更されたときに実行したい処理を登録する
signal volume_changed

## 設定の読み書きクラスのインスタンス。initとchangedメソッドを持たせる。
var _storage_instance: RefCounted

## バスのインデックス
var _bus_index: int

## スライダーのインスタンス
var _slider: Slider

## 最大値
var _max_value: float

func _ready():
	$Label.text = label_text

## 初期化[br]
## [param storage] 設定の読み書きクラスのインスタンス[br]
func init(storage: RefCounted):
	_storage_instance = storage
	_slider = $HSlider
	_max_value = _slider.max_value
	var vol = storage.init(key_string, round(_max_value) as int, default_volume)
	_bus_index = AudioServer.get_bus_index(key_string)
	_slider.value = round(vol)
	_set_volume(_slider.value)
	_slider.value_changed.connect(_value_changed)

## 0-1の値を受け取ってバスのボリュームを設定する。[br]
## [param new_value] 設定するボリューム。0-1[br]
func _set_volume(new_value: float):
	var v = clamp(new_value, 0.0, _max_value)
	var db = _volume_to_db(v)
	AudioServer.set_bus_volume_db(_bus_index, db)
	
## 値が変更された時に呼び出す。変更値をintに変換して登録したメソッドを呼び出す。
func _value_changed(new_value: float):
	_set_volume(new_value)
	volume_changed.emit()
	_storage_instance.changed(round(new_value) as int)

## ボリュームをdBに変換する。
## 1ごとに-6dB。0の時は消音のため-100
func _volume_to_db(volume: int) -> float:
	if volume > 0:
		return -6.0 * (5-volume)
		
	return -100
