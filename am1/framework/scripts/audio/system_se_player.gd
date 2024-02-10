extends Node

## Autoloadに登録するシステム効果音プレイヤークラス SystemSePlayer

## SEPlayerをアタッチしているシーンのパス
const SEPlayerScene := preload("res://am1/framework/scenes/se_player.tscn")

## プレイヤー
var player: SEPlayer

## 子供にSEPlayerクラスを配置
func _ready():
	player = SEPlayerScene.instantiate()
	add_child(player)



