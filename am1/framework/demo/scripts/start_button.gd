extends Button

func _on_pressed():
	if GameState.can_control:
		SceneChanger.change_scene("res://am1/framework/demo/scenes/cold_start_game.tscn")
