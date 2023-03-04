extends "res://Characters/FPS.gd"

@export_range(0, 100) var dash_speed = 50
@export_range(0, 1) var dash_duration = 0.1

func _process(_delta):
	if Input.is_action_just_pressed("shift"):
		dash()

func dash():
	var old_speed = speed
	
	# Change speed
	speed = dash_speed
	
	# Wait for duration
	await get_tree().create_timer(dash_duration).timeout
	
	# Slow player back
	speed = old_speed
