extends CSGBox3D

@export var quantity: int = 5

var teleport_points = []

func _ready():
	add_marks()
	add_to_group("Teleportable")
	
func add_marks():
	teleport_points.clear()
	
	var max_size = max(scale.x, scale.y, scale.z)
	var gap = max_size / quantity
	var offset = gap / 2
	
	for mark in quantity:
		var global_position_for_row = global_position - scale / 2
		var mark_position = Vector3(scale.x / 2, scale.y, mark * gap + offset)
		
		var new_sphere = Helpers.add_sphere(mark_position + global_position_for_row)
		teleport_points.append(new_sphere)
