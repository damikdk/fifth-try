extends CharacterBody3D

@export_range(0, 30) var speed = 6
@export_range(0, 30) var jump_force = 10
@export_range(0, 30) var mass = 4
@export_range(0, 3) var mouse_sense = 0.1

var max_speed_vector = Vector3(speed, speed, speed)
var is_camera_locked = false
var is_movement_locked = false

var vertical_vector = Vector3()
var horizontal_vector = Vector3()

var last_mouse_position = Vector2()

@onready var camera: Camera3D = $Camera
@onready var cursor: ColorRect = $Camera/ColorRect


func _ready():
	# hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed == false:
		get_tree().change_scene_to_file("res://Menu/MainMenu.tscn")
		
	if event is InputEventMouseMotion && !is_camera_locked:
		# rotate camera
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		last_mouse_position = event.position

func _physics_process(delta):
	if is_movement_locked:
		return
	
	var direction = Vector3()
	
	# get keyboard input
	var h_rot = transform.basis.get_euler().y
	var f_input = Input.get_axis("move_forward", "move_backward")
	var h_input = Input.get_axis("move_left", "move_right")

	direction = Vector3(h_input, 0, f_input).rotated(up_direction, h_rot).normalized()
	horizontal_vector = direction * speed
	
	# jumping and gravity
	if is_on_floor():
		vertical_vector = Vector3.ZERO
	else: 
		vertical_vector += -up_direction * 9.8 * mass * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_vector.y += jump_force
	
	var result_vector = horizontal_vector + vertical_vector
#	result_vector = result_vector.clamp(result_vector, max_speed_vector)
	
	# make it move
	velocity = result_vector
	
	move_and_slide()

