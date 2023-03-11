extends CSGSphere3D

const HP_MIN = 0
const HP_MAX = 10

@export_range(HP_MIN, HP_MAX) var HP = HP_MAX
@export var initial_mood: Mood

func _ready():
	var shader_state = MOODS_ARRAY[initial_mood]
	change_shader(shader_state, 0)

func _process(_delta):
	if Input.is_action_just_pressed("left_mouse"):
		take_damage(1)
		
	if Input.is_action_just_pressed("right_mouse"):
		heal(1)
		
	if Input.is_action_just_pressed("1"):
		change_shader(CALM_SHADER_PARAMETERS)
		
	if Input.is_action_just_pressed("2"):
		change_shader(EXCITED_SHADER_PARAMETERS)
		
	if Input.is_action_just_pressed("3"):
		change_shader(ANGRY_SHADER_PARAMETERS)

func take_damage(damage: float):
	HP = max(HP_MIN, HP - damage)
	update_shader()

func heal(amount: float):
	HP = min(HP + amount, HP_MAX)
	update_shader()
	
func update_shader():
	var tween = get_tree().create_tween()
	tween.tween_property(material, "shader_parameter/" + "emission_intensity", 1.7 * HP / 10.0, 1)
	
func change_shader(shader_state, duration: float = 15):
	var tween = get_tree().create_tween().set_parallel(true)
	
	for param in shader_state:
		tween.tween_property(material, "shader_parameter/" + param, shader_state[param], duration)
		
		# Other way
		# material.set_shader_parameter(param, CALM_SHADER_PARAMETERS[param])


# Keep this things the same. I don't want to handle godot enum stuff
enum Mood { CALM, EXCITED, ANGRY }
const MOODS_ARRAY = [CALM_SHADER_PARAMETERS, EXCITED_SHADER_PARAMETERS, ANGRY_SHADER_PARAMETERS]

const CALM_SHADER_PARAMETERS = {
	"base_color_shadow": Color(0, 0, 1),
	"base_color_highlight": Color(1, 0, 1),
	"base_color_blend": 1.2,
	"color_modulate_frequency": 0.1,
	
	"noise_displacement": 0.1, # how far from center noise goes
	"noise_scale": 1.6, # ершистость
	"noise_time_scale": 0.1, # how fast wobbling goes
	"alpha_distance_min": 0.5, # change this, not alpha_distance_max	
	"alpha_distance_max": 1.25,
	"alpha_time_scale": 0.1, # alpha wobbling speed
	"emission_intensity": 1.7, # strange
	"highlight_intensity": 4.7,
}

const EXCITED_SHADER_PARAMETERS = {
	"base_color_shadow": Color(0, 0, 1),
	"base_color_highlight": Color(1, 0, 1),
	"base_color_blend": 1.2,
	"color_modulate_frequency": 0.1,
	
	"noise_displacement": 0.1, # how far from center noise goes
	"noise_scale": 20,
	"noise_time_scale": 0.9, # how fast wobbling goes
	"alpha_distance_min": 0.5, # change this, not alpha_distance_max	
	"alpha_distance_max": 1,
	"alpha_time_scale": 0.1, # alpha wobbling speed
	"emission_intensity": 0.8, # strange
	"highlight_intensity": 0.1,
}

const ANGRY_SHADER_PARAMETERS = {
	"base_color_shadow": Color(0, 0, 0),
	"base_color_highlight": Color(0, 0, 1),
	"base_color_blend": 1.35,
	"color_modulate_frequency": 0.1,
	
	"noise_displacement": 0.54, # how far from center noise goes
	"noise_scale": 20,
	"noise_time_scale": 1.7, # how fast wobbling goes
	"alpha_distance_min": 0.5, # change this, not alpha_distance_max	
	"alpha_distance_max": 1,
	"alpha_time_scale": 0.1, # alpha wobbling speed
	"emission_intensity": 0, # strange
	"highlight_intensity": 0.1,
}
