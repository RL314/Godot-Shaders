extends Node

@onready var noise = $Label.material.get_shader_parameter("noise").noise
var omega = 1.4


func _ready():
	$Label.material.set_shader_parameter("swizzling_omega", omega)

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	noise.offset = Vector3(
		10 * t, 
		-2 * t, 
		0
	)
	noise.fractal_gain = sin(omega * t) + 0.5
