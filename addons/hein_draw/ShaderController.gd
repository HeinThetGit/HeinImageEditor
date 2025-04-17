@tool
extends CanvasItem
class_name ShaderController


func _set_shader_float(value : float, parm : String):
	var m = material
	if m is ShaderMaterial:
		m.set_shader_parameter(parm, value)

func _set_shader_bool(value : bool, parm : String):
	var m = material
	if m is ShaderMaterial:
		m.set_shader_parameter(parm, value)

func _set_blend_mode(type : bool):
	var m = material
	if m is CanvasItemMaterial:
		m.blend_mode = type

func _set_modulate_color(value : Color):
	modulate = value
	
func _set_shader_vec2(value : Vector2, parm : String):
	var m = material
	if m is ShaderMaterial:
		m.set_shader_parameter(parm, value)
