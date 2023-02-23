extends Control

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	var refresh_rate = DisplayServer.screen_get_refresh_rate()
	Engine.set_physics_ticks_per_second(refresh_rate)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed == false:
		get_tree().quit()
