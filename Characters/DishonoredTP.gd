extends "res://Characters/FPS.gd"

@export_range(1, 20) var ray_length = 15
var ray_from: Vector3 = Vector3()
var ray_to: Vector3 = Vector3()

func _process(_delta):
	get_tree().call_group("TeleportCursor", "queue_free")

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		cursor.visible = false 
		
		ray_from = camera.project_ray_origin(last_mouse_position)
		ray_to = ray_from + camera.project_ray_normal(last_mouse_position) * ray_length
		var hit_result = Helpers.raycast(ray_from, ray_to, [self])
		
		if hit_result:
			if hit_result.collider.is_in_group("Teleportable"):
				Helpers.add_sphere(hit_result.position, 0.2).add_to_group("TeleportCursor")

	if Input.is_action_just_released("right_mouse"):
		cursor.visible = true 
		
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

