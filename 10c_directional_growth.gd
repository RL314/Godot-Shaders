extends Node2D

# IMPORTANT
# This example does not work without 
# Forward+ render mode and enabling use_hdr_2d on the SubViewports
# Otherwise when passing lastFrame with SubViewport.get_texture(), 
# the texture is converted from (supposedly) 32-bit for each channel to 8-bit per channel, 
# which leaves insufficient precision for coordinates representation

# IMPORTANT
# This demo fails despite the previous fix. Redo this agin in the future with compute shader.
# More details can be obtained from the !!! critical failure in 10c_directional_grwoth.gdshader

var frame_duration := 1.#1./30.
var t_from_last := 0.
var iFrame: int = 0

@onready var mat: ShaderMaterial = $SubViewport/Simulation.material

func _ready() -> void:
	#mat.set_shader_parameter("seed", randi())
	#mat.get_shader_parameter("branchingProbNoise").noise.seed = randi()
	set_size(128)
func set_size(l: int) -> void:
	var size := Vector2(l,l)
	
	var display_size := Vector2(512, 512)
	$Display.position = display_size / 2
	$Display.scale = display_size / float(l)
	$DebugSprite2D.position = $Display.position + Vector2(display_size.x, 0)
	$DebugSprite2D.scale = $Display.scale
	
	$SubViewport.size = size
	$SubViewport/Simulation.position = size/2
	$SubViewport/Simulation.texture.width = l
	$SubViewport/Simulation.texture.height = l
	mat.set_shader_parameter("size", Vector2i(size))
	
	$BufferSubViewport.size = size
	$BufferSubViewport/BufferSprite2D.position = size/2
	
	$ColorRect.size = size
	$ColorRect.scale = $Display.scale

func _physics_process(dt: float) -> void:
	t_from_last += dt
	if t_from_last >= frame_duration:
		t_from_last -= frame_duration
		iFrame += 1
		step()
	if iFrame % 20 == 1:
		debug()
	
func step() -> void:
	mat.set_shader_parameter("iFrame", iFrame)
	print(iFrame)
	
	# (1) feed last frame to mat.lastFrame
	var texture: Texture2D = $BufferSubViewport.get_texture()
	mat.set_shader_parameter("lastFrame", texture)
	$SubViewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
	$BufferSubViewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE


func debug():
	# there are reports on Godot ignoring the alpha channel of textures
	# https://github.com/godotengine/godot/issues/108535
	var texture: Texture2D = $BufferSubViewport.get_texture()
	#var texture: Texture2D = $DebugSprite2D.texture
	#print(texture.has_alpha()) # false for both the viewport texture and the sprite2D texture
	var img: Image = texture.get_image()
	var err := img.save_png("res://images/debug/debug%d.png" % iFrame)
	#var err := img.save_webp("res://images/debug/debug%d.webp" % iFrame)
	
	
