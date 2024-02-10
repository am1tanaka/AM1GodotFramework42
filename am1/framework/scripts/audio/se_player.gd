class_name SEPlayer
extends Node

## システム効果音を管理するクラスSEPlayer
## system_se_player.gdの子供に配置される。

## 種類。
enum Clip {
	None = -1,
	Click,
	Start,
	Cancel,
}

## 音源数
const CHANNEL_MAX := 8

## 出力バス名
const BUS:= "Se"

## 音源を設定する配列。enumのSEと同順に設定する。
@export var se_resources: Array[AudioStream]

## 再生する種類
var _audio_players: Array[AudioStreamPlayer]

## インスタンスの設定
func _ready():
	while (_audio_players.size() < CHANNEL_MAX):
		var player = AudioStreamPlayer.new()
		player.bus = BUS
		add_child(player)
		_audio_players.append(player)
	
## 再生
func play(clip: Clip):
	var player = _get_next_player()
	player.stop()
	player.stream = se_resources[clip]
	player.play()

## 再生するプレイヤーを返す
func _get_next_player() -> AudioStreamPlayer:
	if !_audio_players[0].playing:
		return _audio_players[0]

	var next = _audio_players[0]
	var time = _audio_players[0].get_playback_position()
	for i in range(1, CHANNEL_MAX):
		if !_audio_players[i].playing:
			return _audio_players[i]
		
		if _audio_players[i].get_playback_position() > time:
			next = _audio_players[i]
			time = _audio_players[i].get_playback_position()

	return next
