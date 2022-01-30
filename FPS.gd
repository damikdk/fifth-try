extends CharacterBody3D

var speed = 6
var max_speed_vector = Vector3(speed, speed, speed)
var jump = 5

var mouse_sense = 0.1

var vertical_vector = Vector3()
var horizontal_vector = Vector3()

@onready var head = $Head
@onready var camera = $Head/Camera

func _ready():
	# hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	camera.global_transform = head.global_transform
		
func _physics_process(delta):
	var direction = Vector3()
	var velocity = Vector3()
	
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
		vertical_vector += -up_direction * 9.8 * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_vector.y += jump 
	
	var result_vector = horizontal_vector + vertical_vector
	result_vector = result_vector.clamp(result_vector, max_speed_vector)
	
	# make it move
	motion_velocity = result_vector
	
	move_and_slide()

