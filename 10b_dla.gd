extends Node2D

var frame_duration := 2./64.
var t_from_last := 0.
var iFrame: int = 0

@onready var mat: ShaderMaterial = $SubViewport/Simulation.material

func _ready() -> void:
	mat.set_shader_parameter("seed", randi())
	set_size(256)
func set_size(l: int) -> void:
	var size := Vector2(l,l)
	
	var display_size := Vector2(512, 512)
	$Display.position = display_size / 2
	$Display.scale = display_size / float(l)
	
	$SubViewport.size = size
	$SubViewport/Simulation.position = size/2
	$SubViewport/Simulation.texture.width = l
	$SubViewport/Simulation.texture.height = l
	mat.set_shader_parameter("size", Vector2i(size))
	mat.set_shader_parameter("nucleusXY", Vector2i(l/2, l-8))
	
	$BufferSubViewport.size = size
	$BufferSubViewport/BufferSprite2D.position = size/2

func _physics_process(dt: float) -> void:
	t_from_last += dt
	if t_from_last >= frame_duration:
		t_from_last -= frame_duration
		iFrame += 1
		step()

func step() -> void:
	mat.set_shader_parameter("iFrame", iFrame)
	print(iFrame)
	
	# (1) feed last frame to mat.lastFrame
	var texture: Texture2D = $BufferSubViewport.get_texture()
	mat.set_shader_parameter("lastFrame", texture)
	# the diffusion process is pseudo-random
	$SubViewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
	$BufferSubViewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
