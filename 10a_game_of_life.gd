extends Node2D

# ! issue 1 - error regarding rendering and reading the same texture
# Godot throws an error 
#   `draw_list_bind_uniform_set: Attempted to use the same texture in framebuffer attachment and a uniform (set: 1, binding: 2), this is not allowed.`
# when the texture of a subviewport is used as 
# a sampler2D in one of its child, as discussed in  
# https://github.com/godotengine/godot/issues/81928
# 
# Copying the texture to another subviewport
# (achieved here by BufferSprite2D and BufferSubViewport)
# and feeding the texture of that pixel-wise identical subviewport
# to the original shader (i.e. Game.material) circumvents this problem. 

# ! issue 2 - controlling frame rate
# I can have no control over its frame rate if the simulation is to be 
# coded purely on gdshader. 
# Since the state of the simulation (characterized by the pixels alone) 
# can be determined nonstochastically on the previous state, one can lock / delay updating
# mat.lastFrame until a timer, controlled by GDScript, ticks. 
# 

var frame_duration := 1./8.
var t_from_last := 0.
var iFrame: int = 0

@onready var mat: ShaderMaterial = $SubViewport/Game.material

func _ready() -> void:
	mat.get_shader_parameter("initialTexture").noise.seed = randi()

func _physics_process(dt: float) -> void:
	t_from_last += dt
	if t_from_last >= frame_duration:
		t_from_last -= frame_duration
		iFrame += 1
		step()

func step() -> void:
	mat.set_shader_parameter("iFrame", iFrame)
	
	# (1) feed last frame to mat.lastFrame
	var texture: Texture2D = $BufferSubViewport.get_texture() # issue 1 if "=$SubViewport.get_texture()"
	mat.set_shader_parameter("lastFrame", texture)
	
	$SubViewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
	$BufferSubViewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
