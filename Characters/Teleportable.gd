extends CSGBox3D

@export var quantity: int = 5

var teleport_points = []

func _ready():
	add_marks()
	add_to_group("Teleportable")
	
func add_marks():
	teleport_points.clear()
	
	var max_size = max(size.x, size.y, size.z)
	var max_scale = max(scale.x, scale.y, scale.z)
	quantity = quantity * max_scale
	var gap = max_size / quantity
	var offset = gap / 2
	
	for mark in quantity:
		var mark_position = Vector3(0, size.y, mark * gap + offset - size.z / 2)
		
		var new_sphere = Helpers.add_local_sphere(self, mark_position)
		teleport_points.append(new_sphere)
