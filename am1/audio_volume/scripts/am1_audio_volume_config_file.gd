class_name AM1AudioVolumeConfigFile
extends RefCounted

## ボリュームをConfigFileで管理するクラス
## シーン管理スクリプトでインスタンスを生成して、スライダーにインスタンスを渡す。

## 設定を保存するファイルパス
const _CONFIG_FILE_PATH := "user://settings.cnf"

## セクション名
const _SECTION_NAME := "audio"

## データ名
const _DATA_KEY_BASE := "volume_%s"

var _key_string: String
var _volume_max: int
var _last_volume: int

static var _config_file: ConfigFile

## テストなど用にstaticをリセットする。
static func init_statics():
	_config_file = null

## 初期化[br]
## [param key] バスや保存時のキー文字列[br]
## [param volume_max] ボリュームの最大値[br]
## [param default_volume] ボリュームの初期値[br]
func init(key: String, volume_max: int, default_volume: int) -> int:
	_key_string = _DATA_KEY_BASE % key
	_volume_max = volume_max
	_last_volume = _load(default_volume)
	return _last_volume

## 変更時に実行する処理[br]
## [param new_value] 新しく設定されたボリューム[br]
func changed(new_value: int):
	if _last_volume == new_value:
		return
	
	_save(new_value)

## データを読み込む
func _load(default_value: int) -> int:
	if !_config_file:
		_config_file = ConfigFile.new()
		var err = _config_file.load(_CONFIG_FILE_PATH)
		if err != OK:
			return default_value

	var result = _config_file.get_value(_SECTION_NAME, _key_string, default_value)
	return result

## 指定のデータを保存する。[br]
## [param save_value] 保存する値
func _save(save_value: int):
	if !_config_file:
		_load(_last_volume)

	if !_config_file:
		print_debug("%sが読み込めませんでした。ボリュームの保存をキャンセルします。" % _CONFIG_FILE_PATH)
		return
		
	_last_volume = save_value
	_config_file.set_value(_SECTION_NAME, _key_string, save_value)
	_config_file.save(_CONFIG_FILE_PATH)
	
