extends Button

func _on_pressed():
	print("start")
	SceneChanger.change_scene("res://am1/framework/demo/scenes/cold_start_game.tscn")
