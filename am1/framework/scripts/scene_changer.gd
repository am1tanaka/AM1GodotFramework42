extends Node

## SceneChanger.

const sub_scene_changer : PackedScene = preload("res://am1/framework/scenes/sub_scene_changer.tscn")

func _ready():
	var sub = sub_scene_changer.instantiate()
	add_child(sub)

func change_scene(data: SceneChangeData):
	print("change scene "+data.screen_cover)
	
	
