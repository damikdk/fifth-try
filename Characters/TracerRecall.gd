extends "res://Characters/FPS.gd"

# I tried to use code from this repo, but rewrite everything. Shot
# https://github.com/unsignedFoo/Tracer_Recall_Godot

@export_range(0, 10) var recall_depth = 3
@export_range(0, 10) var recall_duration = 1
@export_range(0, 100) var position_record_frequency = 0.1

var timer_position_record = Timer.new()
var teleport_points = []

func _ready():
	# hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	timer_position_record.set_wait_time(position_record_frequency)

	add_child(timer_position_record)
	timer_position_record.timeout.connect(self.write_position)
	timer_position_record.start()

func _process(_delta):
	if Input.is_action_just_pressed("E"):
		recall()

func write_position():
	Helpers.add_sphere(global_transform.origin, 0.1)
	teleport_points.append(global_transform)
	
	if teleport_points.size() > recall_depth / position_record_frequency:
		teleport_points.pop_front()

func recall():
	timer_position_record.set_paused(true)
	
	is_camera_locked = true
	is_movement_locked = true
	
	var tween_tp = get_tree().create_tween()
	
	# Prepare arrays
	teleport_points.reverse()
	
	var point_to_point_gap = float(recall_duration) / teleport_points.size()
	
	for index in teleport_points.size():
		tween_tp.tween_property(self, "global_transform", teleport_points[index], point_to_point_gap)
	
	tween_tp.play()
	
	await tween_tp.finished

	is_camera_locked = false
	is_movement_locked = false
	
	teleport_points.clear()
	
	timer_position_record.set_paused(false)
	
