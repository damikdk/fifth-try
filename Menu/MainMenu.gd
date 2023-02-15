extends Control

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed == false:
		get_tree().quit()
