extends CharacterBody3D

var speed = 6
var max_speed_vector = Vector3(speed, speed, speed)
var jump = 10
var mass = 5

var mouse_sense = 0.1

var ray_length = 20
var ray_from: Vector3 = Vector3()
var ray_to: Vector3 = Vector3()

var vertical_vector = Vector3()
var horizontal_vector = Vector3()

var last_mouse_position = Vector2()

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera

func _ready():
	# hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		get_tree().quit()
		
	if event is InputEventMouseMotion:
		# rotate camera
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		last_mouse_position = event.position

	camera.global_transform = head.global_transform
	
func _process(delta):
	
	get_tree().call_group("Cursor", "queue_free")

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		ray_from = camera.project_ray_origin(last_mouse_position)
		ray_to = ray_from + camera.project_ray_normal(last_mouse_position) * ray_length
		var hit_result = Helpers.raycast(ray_from, ray_to, [self])
		
		if hit_result:
			if hit_result.collider.is_in_group("Teleportable"):
				Helpers.add_sphere(hit_result.position, 0.2).add_to_group("Cursor")

	if Input.is_action_just_released("right_mouse"):
		ray_from = camera.project_ray_origin(last_mouse_position)
		ray_to = ray_from + camera.project_ray_normal(last_mouse_position) * ray_length
		var hit_result = Helpers.raycast(ray_from, ray_to, [self])

		if hit_result:
			if hit_result.collider.is_in_group("Teleportable"):
				
				var points = hit_result.collider.teleport_points
				
				if (points.size() > 0):
					var closest_point = points[0]
					var minimal_distance = 9999
					
					for point in points:
						var distance_from_hit = hit_result.position.distance_to(point.global_position)
						
						if distance_from_hit < minimal_distance:
							closest_point = point
							minimal_distance = distance_from_hit

					var new_position = closest_point.global_position + Vector3(0, 2, 0)
					global_position = new_position 

func _physics_process(delta):
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
		vertical_vector.y += jump
	
	var result_vector = horizontal_vector + vertical_vector
	result_vector = result_vector.clamp(result_vector, max_speed_vector)
	
	# make it move
	velocity = result_vector
	
	move_and_slide()

