class_name AudioPlayer
extends AudioStreamPlayer

## ボリュームを含めた曲の再生や停止をするAudioStreamPlayerを継承したクラスAudioPlayer

## 消音するデシベル
const MUTE_DB := -100.0

## 動作モード
enum Mode {
	Standby,		## 待機中
	FadeOut,		## フェードアウトして曲を停止
	VolumeChange,	## ボリューム変更して曲は鳴らし続ける
}

## フェード用のバス名
const FADE_BUS_NAME := "BgmFade"

## 対象のバスのインデックス
@onready var _bus_index := AudioServer.get_bus_index(FADE_BUS_NAME)

## 動作モード
var _mode := Mode.Standby

## フェード経過秒数
var _fade_time: float

## フェード秒数
var _fade_seconds: float

## 開始時のボリューム
var _start_volume: float

## 目的のボリューム
var _target_volume: float

## 曲を再生[br]
## [param from_position] 再生開始位置
## [param volume] 0-1で表すボリューム
func play_bgm(from_position := 0.0, volume := 1.0):
	AudioServer.set_bus_volume_db(_bus_index, linear_to_db(volume))
	play(from_position)

## フェードアウトを開始する。[br]
## [param sec] フェードアウトの秒数
func fade_out(sec: float):
	_start_volume = db_to_linear(AudioServer.get_bus_volume_db(_bus_index))
	_target_volume = 0
	_fade_seconds = sec
	_fade_time = 0
	_mode = Mode.FadeOut

## ボリュームを変更
## [param target_volume] 目的のボリュームを0-1で指定。消音するなら0
## [param sec] 変化秒数
func change_volume(target_volume: float, sec: float):
	_start_volume = db_to_linear(AudioServer.get_bus_volume_db(_bus_index))
	_target_volume = target_volume
	_fade_seconds = sec
	_fade_time = 0
	_mode = Mode.VolumeChange
	
## 更新
func _process(delta):
	if _mode == Mode.Standby:
		return

	# ボリューム調整	
	_fade_time += delta
	var t = min(_fade_time / _fade_seconds, 1.0)
	
	var db = lerp(_start_volume, _target_volume, t)
	AudioServer.set_bus_volume_db(_bus_index, linear_to_db(db))
	
	# 継続チェック
	if _fade_time < _fade_seconds:
		return

	# 終了
	if _mode == Mode.FadeOut:
		stop()

	_mode = Mode.Standby

