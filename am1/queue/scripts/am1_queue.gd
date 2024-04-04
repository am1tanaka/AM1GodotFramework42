class_name AM1Queue
extends RefCounted

## Queue管理クラス
## (C) 2024 TANAKA Yu
## MIT License

const DEFAULT_MAX_COUNT = 256

## キュー
var _queue := []
var _max_count := DEFAULT_MAX_COUNT

## 先頭データのインデックス
var _start_index := 0

## データ数
var _count := 0
var count: int:
	get:
		return _count

## 書き込むインデックス。
var next_index: int:
	get:
		return (_start_index+count) % _max_count

## コンストラクタ。
func _init(arg_max := DEFAULT_MAX_COUNT):
	if arg_max <= 0:
		return
	set_max_count(arg_max)

## 最大値を変更する。
## データが記録されているときは失敗してfalseを返す。
func set_max_count(arg_max: int) -> bool:
	if arg_max <= 0:
		return false
	
	if count > 0:
		return false
	_max_count = arg_max
	return true

## キューに登録されているデータを削除
func clear():
	_count = 0

## データを登録する[br]
## [param data] 登録するデータ[br]
## [param can_overwrite] データが記録可能数を越えるときに歌垣するならtrue。省略すると登録を失敗させて、falseを返す。[br]
## 登録できたらtrue。登録に失敗したらfalse。
func enqueue(data, can_overwrite := false) -> bool:
	if !can_overwrite and count >= _max_count:
		return false

	# データを追加
	if count < _max_count:
		if _queue.size() < _max_count:
			_queue.append(data)
		else:
			_queue[next_index] = data
		_count += 1
		return true

	# ループ上書き書き込み
	_queue[next_index] = data
	_start_index = (_start_index + 1) % _max_count
	return true

## 先頭からデータを取り出して返す。
## データが未登録ならfalse
func dequeue():
	if count == 0:
		return false
	_count -= 1

	var res = _queue[_start_index]
	_queue[_start_index] = null
	_start_index = (_start_index + 1) % _max_count
	return res

## 指定のインデックスのデータを返す。
## 0が先頭のデータ。
## 最後がcount-1。
## データが未登録のときはfalseを返す。
func peek(index: int):
	if count == 0:
		return false

	var ref_index = (_start_index + index) % _max_count
	return _queue[ref_index]
