extends Label

func _ready():
	text = "Ver " + ProjectSettings.get_setting("application/config/version")
	

