shader_type spatial;
render_mode blend_mix;

uniform vec4 base_color_shadow = vec4(0.5, 0.0, 0.0, 1.0);
uniform vec4 base_color_highlight = vec4(0.0, 0.5, 0.0, 1.0);
uniform float base_color_blend : hint_range(0.1, 2.0, 0.05) = 1.2;
uniform float color_modulate_frequency : hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float noise_displacement : hint_range(0.1, 1, 0.01) = 0.3;
uniform float noise_scale : hint_range(1, 20, 0.1) = 7.0;
uniform float noise_time_scale : hint_range(0.1, 10, 0.1) = 1.0;
uniform float alpha_distance_min : hint_range(0.5, 1.5, 0.01) = 1.08;
uniform float alpha_distance_max : hint_range(1.0, 2.0, 0.01) = 1.6;
uniform float alpha_time_scale : hint_range(0.1, 10, 0.1) = 1.0;
uniform float emission_intensity : hint_range(0.0, 15.0, 0.1) = 2.0;
uniform float highlight_intensity : hint_range(0.1, 10.0, 0.1) = 3.0;

varying vec3 normal_norm;
varying vec3 vertex_local;
varying float vertex_d;

// Generic 3-in-1-out noise function from https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
vec4 mod289(vec4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 perm(vec4 x) {
	return mod289(((x * 34.0) + 1.0) * x);
}

float noise(vec3 p) {
	vec3 a = floor(p);
	vec3 d = p - a;
	d = d * d * (3.0 - 2.0 * d);

	vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
	vec4 k1 = perm(b.xyxy);
	vec4 k2 = perm(k1.xyxy + b.zzww);

	vec4 c = k2 + a.zzzz;
	vec4 k3 = perm(c);
	vec4 k4 = perm(c + 1.0);

	vec4 o1 = fract(k3 * (1.0 / 41.0));
	vec4 o2 = fract(k4 * (1.0 / 41.0));

	vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
	vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

	return o4.y * d.y + o4.x * (1.0 - d.y);
}

// Simple function used for generating "waves" for modulating the vertex displacement over time
// Creates different waves for x, y and z (w1, w2 and w3) + one constant rotation around one axis
vec3 wave(float time) {
	float w1 = 0.134 * cos(2.874 * time) + 0.536 * sin(3.574 * time);
	float w2 = 0.446 * sin(2.567 * time) + 0.357 * cos(3.367 * time) + 5.746 * time;
	float w3 = 0.364 * cos(2.745 * time) + 0.256 * sin(3.645 * time);
	return vec3(w1, w2, w3);
}

void vertex() {
	// Getting the normalized normal vector (pointing out of the sphere) in order to displace the vertices along the axis of the normal
	normal_norm = normalize(NORMAL);
	VERTEX += noise_displacement * noise(VERTEX * noise_scale + wave(noise_time_scale * TIME)) * normal_norm;
	
	// Computing distance from new vertex location to center, will be used in fragment shader
	vertex_local = VERTEX;
	vertex_d = distance(vertex_local, vec3(0.0));
}

void fragment() {
	// Animating transparency (alpha) based on distance from sphere center using periodic variations in the treshold
	float alpha_distance_min_varying = alpha_distance_min + 0.05 * alpha_distance_min * cos(2.32 * alpha_time_scale * TIME) + 0.05 * alpha_distance_min * cos(5.17 * alpha_time_scale * TIME) + 0.04 * alpha_distance_min * sin(7.32 * alpha_time_scale * TIME);
	ALPHA = smoothstep(alpha_distance_min_varying, alpha_distance_max, vertex_d);
	
	// Setting the base colors of the orb, blending shadow and highlight color by using smoothstep and vertex distance from center
	ALBEDO = base_color_shadow.rgb + (base_color_highlight.rgb * smoothstep(base_color_blend - base_color_blend * 0.25, base_color_blend + base_color_blend * 0.25, vertex_d));
	
	// Animating (modulating) the base color using small periodic variations in red, green and blue channels 
	ALBEDO += vec3(0.067 * sin(5.346 * color_modulate_frequency * TIME), 0.058 * cos(7.346 * color_modulate_frequency * TIME), 0.073 * sin(3.346 * color_modulate_frequency * TIME));
	
	// Adjusting highlight intensity based on vertex distance from center. Larger values for highlight_intensity will darken areas with vertex_d < 1 and brighten areas with vertex_d > 1
	ALBEDO *= pow(vertex_d, highlight_intensity);
	
	// Making the material emissive by multiplying the albedo by an intensity factor
	EMISSION = emission_intensity * ALBEDO;
}