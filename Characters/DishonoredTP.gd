extends "res://Characters/FPS.gd"

@export_range(1, 20) var ray_length = 15
var ray_from: Vector3 = Vector3()
var ray_to: Vector3 = Vector3()

func _ready():
	# hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta):
	get_tree().call_group("TeleportCursor", "queue_free")

	# Show if node infront is teleportable
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		cursor.visible = false 
		
		# Raycast infront
		var hit_result = hitcastTeleportable()
		
		if hit_result is Dictionary:
			# If node infront is teleportable, show sphere in hit location
			
			Helpers.add_sphere(hit_result.position, 0.2).add_to_group("TeleportCursor")

	# If there is teleportable infront, find closest TP point on it and TP
	if Input.is_action_just_released("right_mouse"):
		cursor.visible = true 
		
		var hit_result = hitcastTeleportable()
		
		if hit_result is Dictionary:
			var points = hit_result.collider.teleport_points
			var closest_teleport_to_hit = findClosestNode(points, hit_result.position)
			var new_position = closest_teleport_to_hit.global_position + Vector3(0, 2, 0)
			global_position = new_position 

func hitcastTeleportable():
	ray_from = camera.project_ray_origin(last_mouse_position)
	ray_to = ray_from + camera.project_ray_normal(last_mouse_position) * ray_length
	var hit_result = Helpers.raycast(ray_from, ray_to, [self])

	if hit_result:
		if hit_result.collider.is_in_group("Teleportable"):
			return hit_result

func findClosestNode(nodes: Array, forPosition: Vector3) -> Node:
	assert(nodes.size() > 0, "ERROR: array of Nodes is empty");
	
	var closest = nodes[0]
	var minimal_distance = 9999
	
	for point in nodes:
		var distance_from_hit = forPosition.distance_to(point.global_position)
		
		if distance_from_hit < minimal_distance:
			closest = point
			minimal_distance = distance_from_hit
		
	return closest
