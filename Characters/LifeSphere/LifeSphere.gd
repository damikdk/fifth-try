extends CSGSphere3D

const HP_MIN = 0
const HP_MAX = 10

@export_range(HP_MIN, HP_MAX) var HP = HP_MAX

func _process(_delta):
	if Input.is_action_just_pressed("shift"):
		take_damage(1)
		
	if Input.is_action_just_pressed("jump"):
		heal(1)

func take_damage(damage: float):
	HP = max(HP_MIN, HP - damage)
	update_shader()

func heal(amount: float):
	HP = min(HP + amount, HP_MAX)
	update_shader()
	
func update_shader():
	material.set_shader_parameter("emission_intensity", 1.7 * HP / 10.0)
