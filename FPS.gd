extends CharacterBody3D

var speed = 6
var max_speed_vector = Vector3(speed, speed, speed)
var jump = 5

var mouse_sense = 0.1

var ray_length = 20
var ray_from: Vector3 = Vector3()
var ray_to: Vector3 = Vector3()

var debug_sphere_size = 0.1

var vertical_vector = Vector3()
var horizontal_vector = Vector3()

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera

func _ready():
	# hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# get mouse input for camera rotation
	if event is InputEventMouseMotion:
		# rotate camera
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
		
		# Cast ray from camera
		ray_from = camera.project_ray_origin(event.position)
		ray_to = ray_from + camera.project_ray_normal(event.position) * ray_length
	
func _process(delta):
	camera.global_transform = head.global_transform
	
	var hit_result =  _raycast()
	
	if hit_result:
		_add_sphere(hit_result.position)
		
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
	
func _raycast() -> Dictionary:
	var space_state = get_world_3d().direct_space_state

	var parameter = PhysicsRayQueryParameters3D.new()
	parameter.from = ray_from
	parameter.to = ray_to

	var hit_result: Dictionary = space_state.intersect_ray(parameter)
	return hit_result
	
func _add_sphere(location: Vector3):
	# Get root scene
	var scene_root = get_tree().root.get_children()[0]

	# Create sphere with low detail of size.
	var sphere = SphereMesh.new()
	sphere.radial_segments = 4
	sphere.rings = 4
	sphere.radius = debug_sphere_size
	sphere.height = debug_sphere_size * 2
	
	# Bright red material (unshaded).
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0)
	material.flags_unshaded = true
	sphere.surface_set_material(0, material)
	
	# Add to meshinstance in the right place.
	var node = MeshInstance3D.new()
	node.mesh = sphere
	node.global_transform.origin = location

	scene_root.add_child(node)
