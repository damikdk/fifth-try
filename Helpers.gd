extends Node3D

const SIZE = 0.1
const COLOR = Color(0.5, 0.5, 0.5)

func raycast(from: Vector3, to: Vector3, exclude: Array) -> Dictionary:
	var space_state = get_world_3d().direct_space_state

	var parameter = PhysicsRayQueryParameters3D.new()
	parameter.from = from
	parameter.to = to
	parameter.exclude = exclude

	var hit_result: Dictionary = space_state.intersect_ray(parameter)
	return hit_result

func add_sphere(location: Vector3, size = SIZE, color = COLOR) -> Node3D:
	# Get root scene
	var scene_root = get_tree().root.get_children()[0]
	
	return add_local_sphere(scene_root, location, size, color)	

func add_local_sphere(parent: Node3D, location: Vector3, size = SIZE, color = COLOR) -> Node3D:

	# Create sphere with low detail of size.
	var sphere = SphereMesh.new()
	sphere.radial_segments = 8
	sphere.rings = 4
	sphere.radius = size
	sphere.height = size * 2
	
	# Gray material (unshaded).
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_unshaded = true
	sphere.surface_set_material(0, material)
	
	# Add to meshinstance in the right place.
	var node = MeshInstance3D.new()
	node.mesh = sphere

	parent.add_child(node)
	
	# You can't do this before adding to tree
	node.transform.origin = location
	
	return node
