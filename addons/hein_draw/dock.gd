# addons/image_editor/dock.gd
@tool
class_name dock
extends Control

@onready var file_dialog = $FileDialog
var cancled : bool
#@onready var load_button = $VBoxContainer/LoadButton
@onready var save_button = %SaveButton
@onready var view : TextureRect = %view
@onready var noti : Label = %noti
@onready var background : Control = %background
@onready var imageView : SubViewportContainer = %SubViewportContainer
@onready var canvas : TextureRect = %canvas
@onready var paintRender : SubViewport = %paintViewPort
@onready var brush : TextureRect = %brush
@onready var brushHandle : Control = %brushHandle
var brushSize : float = 50
@onready var line : Line2D = %Line2D
@onready var pointer : Control = %pointer

var randomBrushRotation : float
var randBrushSize : float
var randBrushPos : float
var useRandBrushCol : bool
var randColFrom : Color = Color.WHITE
var randColTo : Color = Color.YELLOW

#Undo Redo
var undoCount : int = 10
var history : Array[Image]
var currentHistory : int
var painterHistory : Array[Image]
var currentPainterHistory : int

var effectShaders : Array[Shader]
var currentEffect : int

var canvasMaterial : ShaderMaterial
var brushMaterial : CanvasItemMaterial
var lineMaterial : CanvasItemMaterial
var paintLayerMaterial : CanvasItemMaterial
var lastStroke : Vector2
var drawing : bool
var seamlessMode : bool
enum StrokeMode {Press, Release, Continuous}
enum BrushMode {Mix, Erase, Mask, Add, Multiply}
var brushMode : BrushMode = BrushMode.Mix
var brushCol : Color
var continuousBrush : bool = false
var brushSlot : int = 0

var path : String
var image: Image
var zoom : float = 1
var minZoom : float = 1
var maxZoom : float = 1
var originalImage: Image

var currentTab : int
var cropStart : Vector2
var cropEnd : Vector2

#@onready var frames : Control = %frames
@onready var frameOptions : OptionButton = %frameOptions
var currentFrame : Control

var init_mouse_position: Vector2
var prev_mouse_position : Vector2 = Vector2.ZERO
var current_mouse_position: Vector2
var init_imageView_position: Vector2

func _ready():
	#file_dialog.connect("confirmed",Callable(save) )
	#file_dialog.set_meta('created_by',self)

	#brush.visible = false
	brushMaterial = %brush.material
	_on_brush_size_value_value_changed(10)
	_on_brush_types_item_selected(0)
	lineMaterial = line.material
	paintLayerMaterial = %paintLayer.material
	canvasMaterial = %canvas.material
	var t : Texture2D = %canvas.texture
	originalImage = t.get_image()
	image =  originalImage.duplicate()
	
	update()
	reset_parm()
	fit()
	_load_brushes()
	_load_effects()
	#%brushTypes.select(0)
	_on_frame_option_item_selected(0)

func _load_effects():
	%frameOptions.clear()
	var path :='res://addons/hein_draw/effects/'
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name !="":
		if file_name.get_extension() == 'gdshader':
			var full_path := path.path_join(file_name)
			#print(full_path)
			var shader : Shader = load(full_path)
			if shader is Shader:
				effectShaders.append(shader)
				%frameOptions.add_item(file_name.get_basename())
				pass
		file_name = dir.get_next()
	dir.list_dir_end()
	
func _load_brushes():
	%brushTypes.clear()
	%brushTypes.add_icon_item(load("res://addons/hein_draw/icons/circle.png"))
	%brushTypes.add_icon_item(load("res://addons/hein_draw/icons/square.png"))
	var path :='res://addons/hein_draw/brushes/'
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name !="":
		if file_name.get_extension() in ['png','jpg', 'bmp']:
			var full_path := path.path_join(file_name)
			#print(full_path)
			var tex : Texture2D = load(full_path)
			if tex is Texture2D:
				%brushTypes.add_item('',tex)
				pass
		file_name = dir.get_next()
	dir.list_dir_end()
			
			
func _color_sample_clicked(s : ColorPickerButton):
	s.hide()
	pass
func _update_rect_size_on_shader(item : CanvasItem, rect_size : Vector2):
	var m = item.material
	if m is ShaderMaterial:
		m.set_shader_parameter('rect_size',rect_size)
		
func fit():
	
	var fitWidth = background.size.x / image.get_width()
	var fitHeight = background.size.y / image.get_height()
	var minimunFit = min(fitWidth, fitHeight)
	imageView.scale = Vector2.ONE * minimunFit
	zoom = minimunFit
	maxZoom = minimunFit * 3
	minZoom = minimunFit * 0.3
	
	%zoomSlider.value = inverse_lerp(minZoom, maxZoom, zoom)
	%zoomSlider.min_value = 0
	%zoomSlider.max_value = 1
	_center_view()
	
	_update_rect_size_on_shader(imageView, Vector2(image.get_size())*zoom)
	var m = imageView.material
	if m is ShaderMaterial:
		m.set_shader_parameter('gridSize',Vector2(image.get_size()))
	#imageView.position = background.size / 2
	#imageView.position -= (Vector2(image.get_size() ) / 2) * imageView.scale

func _center_view():
	if !background:
		return
	imageView.position = background.size / 2
	imageView.position -= (Vector2(image.get_size() ) / 2) * imageView.scale

	
func reset_parm():

	%brushSizeValue.value = 10
	_on_brush_color_color_changed(Color.WHITE)
	%brushBlend.selected = 0
	brushMode = BrushMode.Mix
	_on_brush_blend_tab_changed(0)
	
	%frameSlider.value = 0
	%frameColor.color = Color.WHITE
	_frame_color_changed(Color.WHITE)
	#%frameOptions.select(0)
	var m = %canvas.material
	if m is ShaderMaterial:
		m.shader.reset_state()
		m.reset_state()
	pass
func _on_file_selected():
	toast(file_dialog.current_path)
	path = file_dialog.current_path
	originalImage = Image.load_from_file(path)
	image = originalImage.duplicate()
	history.clear()
	
	currentHistory = 0
	update()
	fit()
	reset_parm()
	#_make_effect_history()
	#var s = %background.size.x / image.get_size().y
	#%SubViewportContainer.scale = Vector2.ONE * s
	#%zoomSlider.value = s
	#update()
	#_apply_brightness(slider.valcreate_from_image()
func update():
	pass
	%canvas.texture = ImageTexture.create_from_image(image)
	%canvas.size = image.get_size()
	%viewport.size = image.get_size()
	#%SubViewportContainer.size = image.get_size()
	%info.text = str(image.get_size()) + " "+ path.get_extension()
	
	cropStart = Vector2.ZERO
	cropEnd = image.get_size()
	paintRender.size = image.get_size()
	_brush_warp(seamlessMode)
	#%viewOutline.custom_minimum_size = Vector2(image.get_size())
	
		
	_update_rect_size_on_shader(imageView, Vector2(image.get_size())*zoom)
	#noti.text = "updating..."
	#await get_tree().create_timer(0.1).timeout
	#noti.text = ""
	#view.texture = ImageTexture.create_from_image(image)
	#view.scale = Vector2.ONE * zoom

func _apply_brightness(brightness: float):
	noti.text = "updating view..."
	#await get_tree().create_timer(0.01).timeout
	
	for y in image.get_height():
		for x in image.get_width():
			var color :  Color = originalImage.get_pixel(x, y)
			var a = color.a
			color *= brightness
			color.a = a
			#image.set_pixelv
			image.set_pixel(x, y, color)
	noti.text = ""

func toast(msg : String):
	noti.text = msg
	#await get_tree().create_timer(3).timeout
	#%noti.text = ""
	pass
func save(savePath : String):
	noti.text = "Saving..."
	await get_tree().create_timer(0.1).timeout
	#save_button.text = "Saving..."
	#var save_path = "res://brightened_image.png"
	var captured = %viewport.get_texture().get_image()
	var f = image.get_format()
	var dd
	var e = savePath.get_extension()
	if e == "jpg" or e == "jpeg":
		dd = captured.save_jpg(savePath)
		#print("saved as jpg")
		#%viewport.
	if e == "png" :
		
		captured.save_png(savePath)
		#print("file saved!")
		#print(savePath)
	toast(e +" Saved! "+ savePath)
	path = savePath
	EditorInterface.get_resource_filesystem().scan_sources()

func _on_brightness_slider_changed(value_changed: float) -> void:
	canvasMaterial.set_shader_parameter('brightness',value_changed)


func _on_revert_button_up() -> void:
	_revert()
	pass # Replace with function body.
func _revert():
	image = originalImage.duplicate()
	history.clear()
	currentHistory = 0
	painterHistory.clear()
	currentPainterHistory = 0
	reset_parm()
	_clear_paint()
	update()
	fit()
		
func _on_zoom_value_changed(value: float) -> void:
	value = lerpf(minZoom, maxZoom, value)
	var zd = value - zoom
	zoom = value
	#imageView.pivot_offset = -Vector2(image.get_size()) / 2
	imageView.scale = Vector2.ONE * value
	var smp = (Vector2(image.get_size()) / 2) * zd
	imageView.position -= smp
	
	_update_rect_size_on_shader(imageView, Vector2(image.get_size()) * zoom)

func _openLoad():
	file_dialog.popup_centered_ratio(1)
	file_dialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
	
func _openSaveAs():
	file_dialog.popup_centered_ratio(1)
	file_dialog.FileMode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
func _on_contrast_value_drag_ended(value_changed: float) -> void:
	
	canvasMaterial.set_shader_parameter("contrast",value_changed)
	pass # Replace with function body.




func _on_save_dialog_visibility_changed() -> void:
	if %saveDialog.visible:
		if path.is_empty():
			%saveDialog.current_file = "untitled.jpg"
		else:
			%saveDialog.current_file = path.get_file()
			%saveDialog.current_path = path
		cancled = false
	else:
		if !cancled:
			save(%saveDialog.current_path)
	

		
	#save(%saveDialog.current_path)
	pass # Replace with function body.


func _on_save_button_button_up() -> void:
	if !path.is_empty():
		save(path)
	else:
		pass
		%saveDialog.current_file = "untitled.jpg"
		%saveDialog.popup_centered_ratio(1)
	
	pass # Replace with function body.


func _on_tint_color_color_changed(color: Color) -> void:
	canvasMaterial.set_shader_parameter("tint_color",color)
	pass # Replace with function body.


func _on_resize_button_button_up() -> void:
	var w =  %width.text.to_float()
	var h = %height.text.to_float()

	image.resize(w,h)
	update()
	fit()
	
	
	pass # Replace with function body.


func _frame_slider_changed(value: float) -> void:
	
	if currentFrame:
		var mt = currentFrame.material
		if mt is ShaderMaterial:
			mt.set_shader_parameter('threshold', value)
			#match frameOptions.selected:
				#1:
					#mt.set_shader_parameter("softness_y",value)
					#var ratio = canvas.size.y / canvas.size.x
					#mt.set_shader_parameter("softness_x",value * ratio)
				#2:
					#pass
		
		
	pass # Replace with function body.


func _frame_color_changed(color: Color) -> void:
	if currentFrame:
		currentFrame.modulate = color
		match frameOptions.selected:
			1:
				pass
	pass # Replace with function body.




func _set_shader_float(value: float, extra_arg_0: String) -> void:
	canvasMaterial.set_shader_parameter(extra_arg_0, value)
	pass # Replace with function body.


func _on_tab_container_tab_changed(tab: int) -> void:
	currentTab = tab
	%cropRect.visible = false
	%pointer.visible = false
	_clear_paint()
	#%brush.visible = false
	#%viewport.render_target_clear_mode = 1
	match tab:
		2:#crop
			%cropRect.visible = true
		3:#draw
			%pointer.visible = true
			%viewport.render_target_clear_mode = 0
			_make_painter_history()
	pass # Replace with function body.


func _on_crop_right_value_changed(value: float) -> void:
	cropEnd.x = roundi(value * image.get_width())
	_update_crop_region()
	pass # Replace with function body.


func _on_crop_buttom_value_changed(value: float) -> void:
	cropEnd.y = roundi( value * image.get_size().y )
	_update_crop_region()
	
	pass # Replace with function body.

func _update_crop_region():
	%cropRect.visible = true
	%cropRect.position = cropStart
	%cropRect.size =  cropEnd - cropStart
	pass
func _on_crop_top_value_changed(value: float) -> void:
	cropStart.y =  roundi(value * image.get_height())
	_update_crop_region()
	#var e = %cropRect.get_end()
	#e.y
	#%cropRect.set_end(e)
	pass # Replace with function body.


func _on_crop_left_value_changed(value: float) -> void:
	cropStart.x =  roundi(value * image.get_width())
	_update_crop_region()
	pass # Replace with function body.

func _rotate_image(dir : int):
	apply_effect()
	image.rotate_90(dir)
	update()
	fit()
	pass
func _on_apply_crop_button_up() -> void:
	%cropRect.visible = false
	var cp = %cropRect.position
	var cs = %cropRect.size
	var captured : Image = %viewport.get_texture().get_image()
	var croppedImage : Image = Image.create(cs.x, cs.y, false, captured.get_format() )
	croppedImage.blit_rect(captured, Rect2(cp.x, cp.y, cs.x, cs.y), Vector2(0,0) )
	
	image = croppedImage
	reset_parm()
	update()
	fit()
	
	pass # Replace with function body.

func _reset_pointer():
	line.clear_points()
	for c in line.get_children():
		if c is Line2D:
			c.clear_points()
	pointer.reparent(%paintLayer)
	pointer.visible = currentTab == 3
	brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		
func _stamp():
	_update_brush_mode()
	pointer.reparent(%paintViewPort,true)
	await get_tree().process_frame
	await get_tree().process_frame
	#await get_tree().process_frame
	_reset_pointer()
	_make_painter_history()
	
	
	

func _get_pointer_pos(mousePos : Vector2):
	return mousePos * (1/zoom) - (imageView.position * (1/zoom) )

	
func _on_canvas_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				if currentTab == 3:
					_reset_pointer()
					if continuousBrush:#for brushes
						_update_brush_mode()
						pointer.reparent(%paintViewPort)
					else:# for strokes
						pointer.reparent(%paintLayer)
				
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				%zoomSlider.value += 0.1
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				%zoomSlider.value -= 0.1
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				init_mouse_position = event.global_position
				init_imageView_position = imageView.position	
		if event.button_index == 1:
			#brush.visible = !event.is_released() && currentTab == 4
			drawing = !event.is_released() && currentTab == 3
		if event.is_released():
			# drawing a straight line from previous mouse position if user hold shift
			if Input.is_key_pressed(KEY_SHIFT):
				if prev_mouse_position.x > 0:
					line.add_point(prev_mouse_position)
			prev_mouse_position = _get_pointer_pos(event.position)
			
			if event.button_index == 1:#When left click is release inside image view
				if currentTab == 3:# in drawing tab
					if !continuousBrush:
						_stamp()
					else:
						_reset_pointer()
						_make_painter_history()
						
	if event is InputEventMouse:
		var pointerPos = _get_pointer_pos(event.position)
		var randPos : Vector2
		#brush.position = pointerPos
		if drawing:
			if useRandBrushCol:
				brush.modulate = randColFrom.lerp(randColTo,randf_range(0,1))
			else:
				brush.modulate = brushCol
				
			if brushSlot > 1:# only custom brushes can have randomness
				brush.size = Vector2.ONE * ( brushSize + randf_range(-randBrushSize, randBrushSize) )
				brush.pivot_offset = brush.size / 2
				brush.rotation_degrees = randf_range(-randomBrushRotation, randomBrushRotation)
				randPos = Vector2.from_angle(randf_range(0, 2*PI)) * randBrushPos
			else:
				brush.size = Vector2.ONE * brushSize
				
			
			
			line.add_point(line.get_local_mouse_position())
			if seamlessMode:
				_add_neighor_brush_point(pointerPos)
				
		_update_neighbor_brushes()
		%brushHandle.position = imageView.get_local_mouse_position() - (brush.size / 2) + randPos
				
	if event is InputEventMouseMotion:
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			current_mouse_position = event.global_position
			imageView.position = init_imageView_position + (current_mouse_position - init_mouse_position)
		#print(event.button_index)
		
	#print("evenr")
	pass # Replace with function body.

func _add_neighor_brush_point(pos : Vector2):
	for c in line.get_children():
		if c is Line2D:
			c.add_point(pos)

func _update_neighbor_brushes():
	for b in brushHandle.get_children():
		if b is TextureRect:
			b.visible = brush.visible
			b.modulate = brush.modulate
			b.texture = brush.texture
			b.size = brush.size
			b.pivot_offset = brush.pivot_offset
			b.rotation = brush.rotation
	for l in line.get_children():
		l.visible = true
		if l is Line2D:
			l.visible = line.visible
			l.width = line.width
			l.texture = line.texture
			l.end_cap_mode = line.end_cap_mode
			l.begin_cap_mode = line.begin_cap_mode
			
func _brush_warp(on):
	if on:
		_update_neighbor_brushes()
		brushHandle.get_node('e').position.x = -%canvas.size.x
		brushHandle.get_node('w').position.x = %canvas.size.x
		brushHandle.get_node('s').position.y = %canvas.size.y
		brushHandle.get_node('n').position.y = -%canvas.size.y
		
		line.get_node('n').position.y = -%canvas.size.y
		line.get_node('s').position.y = %canvas.size.y
		line.get_node('w').position.x = %canvas.size.x
		line.get_node('e').position.x = -%canvas.size.x
		
		for c in brush.get_children():
			c.visible = true
		for c in line.get_children():
			c.visible = true
			
	else:
		for c in brush.get_children():
			c.visible = false
		for c in line.get_children():
			c.visible = false
	_update_brush_mode()
	
func _on_brush_color_color_changed(color: Color) -> void:
	brushCol = color
	brush.modulate = color
	line.default_color = color
	for c in line.get_children():
		if c is Line2D:
			c.default_color = color
	for c in brushHandle.get_children():
		if c is TextureRect:
			c.modulate = color
	pass # Replace with function body.


func _create_new_image(width : int, height : int, color : Color) -> void:
	#_on_revert_button_up()
	path = ""
	_clear_paint()
	originalImage = Image.create(width, height, false, Image.FORMAT_RGBA8)
	originalImage.fill(color)
	image = originalImage.duplicate()
	update()
	fit()
	pass # Replace with function body.


func _update_brush_mode():
	match brushMode:
		BrushMode.Mix:
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		BrushMode.Erase:
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
			lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
		BrushMode.Mask:
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		BrushMode.Add:
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			
	pass
func _on_brush_blend_tab_changed(tab: int) -> void:
	#brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	#paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	match tab:
		0:
			brushMode = BrushMode.Mix
			paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
			
		1:
			brushMode = BrushMode.Erase
			paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA

		2:
			brushMode = BrushMode.Mask
			paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB

		3:
			brushMode = BrushMode.Add
			paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	_reset_pointer()
	pass # Replace with function b
	

func _on_brush_size_value_value_changed(value: float) -> void:
	
	brush.size = Vector2.ONE * value
	brushSize = value
	for c in brush.get_children():
		if c is TextureRect:
			c.size = brush.size
			
	line.width = brush.size.y
	for c in line.get_children():
		if c is Line2D:
			c.width = line.width
			
	%brushSizeText.text = str(value)
	_update_neighbor_brushes()
	pass # Replace with function body.


func _flipX():
	apply_effect()
	image.flip_x()
	update()
	fit()
	
func _flipY():
	apply_effect()
	image.flip_y()
	update()
	fit()

func undo():
	if currentHistory > 0:
		currentHistory -= 1
		_apply_effect_history()
	else:
		image = originalImage.duplicate()
		update()
		fit()
		
func redo():
	if currentHistory < history.size() - 1:
		currentHistory += 1
		_apply_effect_history()
	
func _apply_effect_history():
	currentPainterHistory = 0
	if currentHistory < history.size():
		image = history[currentHistory]
	_clear_paint()
	reset_parm()
	update()
	fit()

func _undo_paint():
	if currentPainterHistory > 0:
		currentPainterHistory -=1
		_apply_paint_history()
	else:
		currentPainterHistory = -1
		#_clear_paint()
	
	
		
		

func _apply_paint_history():
	_clear_paint()
	var p = painterHistory[currentPainterHistory].duplicate()
	%paintSnap.texture = ImageTexture.create_from_image(p)
	
	%paintSnap.visible = true
	await get_tree().process_frame
	await get_tree().process_frame
	%paintSnap.visible = false
	#print('applied paint history index '+str(currentPainterHistory))
	
func _redo_paint():
	if currentPainterHistory < painterHistory.size() - 1:
		currentPainterHistory +=1
		_apply_paint_history()
	
		
		

func _make_painter_history():
	var paint = %paintViewPort.get_texture().get_image()
	
	painterHistory.append(paint)
	if painterHistory.size() > undoCount:
		painterHistory.remove_at(0)
	currentPainterHistory = painterHistory.size() - 1
	#print('made paint history index '+str(currentPainterHistory))
	
func _make_effect_history():
	pointer.visible = false
	image = %viewport.get_texture().get_image()
	history.append(image)
	if history.size() > undoCount:
		history.remove_at(0)
	currentHistory = history.size() - 1

func apply_paint():
	_make_effect_history()
	_clear_paint()
	update()
	
func apply_effect():
	_make_effect_history()
	_on_frame_option_item_selected(currentEffect)
	_clear_paint()
	reset_parm()
	update()
	fit()

func _clean():
	_clear_paint()
	_make_painter_history()
func _clear_paint():
	%paintViewPort.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	#paintRender.render_target_update_mode = SubViewport.UPDATE_ONCE
	prev_mouse_position = Vector2(-1,-1)#
	pass


func _on_create_dialog_confirmed() -> void:
	_create_new_image(%initWidth.text.to_int(), %initHeight.text.to_int(), %initColor.color)
	pass # Replace with function body.


func _on_brush_size_text_text_submitted(new_text: String) -> void:
	#_on_brush_size_value_value_changed(new_text.to_int())
	%brushSizeValue.value = new_text.to_int()
	pass # Replace with function body.


func _effect_bool_changed(value : bool, parm : String, p : Control):
	var m = %canvas.material
	if m is ShaderMaterial:
		m.set_shader_parameter(parm, value)
		
func _effect_color_changed(value : Color, parm : String, p : Control):
	var m = %canvas.material
	if m is ShaderMaterial:
		m.set_shader_parameter(parm, value)

func _effect_float_value_changed(value : String, parm : String, p : Control):
	var s : HSlider = p.get_node('slider')
	s.value = value.to_float()
	
func _effect_int_value_changed(value : String, parm : String, p : Control):
	var m = %canvas.material
	if m is ShaderMaterial:
		m.set_shader_parameter(parm, value.to_int())
	
func _effect_vec2_value_changed(value : String, parm : String, p : Control):
	var x : LineEdit = p.get_node('x')
	var y : LineEdit = p.get_node('y')
	var v : Vector2 = Vector2(x.text.to_float(), y.text.to_float())
	var m = %canvas.material
	if m is ShaderMaterial:
		m.set_shader_parameter(parm, v)
	
func _effect_float_slider_changed(value : float, parm : String, p : Control):
	p.get_node('value').text = '%.2f' % value
	var m = %canvas.material
	if m is ShaderMaterial:
		m.set_shader_parameter(parm, value)


func _on_frame_option_item_selected(index: int) -> void:
	currentEffect = index
	for c in %effectParms.get_children():
		c.queue_free()
	var m = ShaderMaterial.new()
	if m is  ShaderMaterial:
		m.shader = effectShaders[currentEffect]
		var v = m.shader.get_shader_uniform_list()
		#print(v)
		for d in v:
			match d.type:
				2:#int uniform
					var p = %uniforms.get_node("int").duplicate()
					p.get_node('name').text = d.name
					var valueBox : LineEdit = p.get_node('value')
					valueBox.text = '%.2f' % 0
					valueBox.text_submitted.connect( Callable(_effect_int_value_changed).bind(d.name, p))
					
					%effectParms.add_child(p)
				5:#vec2 uniform
					var p = %uniforms.get_node("vec2").duplicate()
					p.get_node('name').text = d.name
					var x : LineEdit = p.get_node('x')
					var y : LineEdit = p.get_node('y')
					x.text = '%.2f' % 0
					y.text = '%.2f' % 0
					x.text_submitted.connect( Callable(_effect_vec2_value_changed).bind(d.name, p))
					y.text_submitted.connect( Callable(_effect_vec2_value_changed).bind(d.name, p))
					%effectParms.add_child(p)
				1:#bool uniform
					var p = %uniforms.get_node("bool").duplicate()
					p.get_node('name').text = d.name
					var checkButton  : CheckButton = p.get_node('value')
					checkButton.button_pressed = false
					m.set_shader_parameter(d.name, false)
					checkButton.toggled.connect(   Callable(_effect_bool_changed).bind(d.name, p) )
					%effectParms.add_child(p)
					
				20:#color uniform
					var p = %uniforms.get_node("color").duplicate()
					p.get_node('name').text = d.name
					var colorpicker  : ColorPickerButton = p.get_node('value')
					colorpicker.color = Color.WHITE
					m.set_shader_parameter(d.name, Color.WHITE)
					colorpicker.color_changed.connect(   Callable(_effect_color_changed).bind(d.name, p) )
					%effectParms.add_child(p)
					
				3:# float uniform
					var p = %uniforms.get_node("float").duplicate()
					p.get_node('name').text = d.name
					var s : HSlider= p.get_node('slider')
					var tb  : LineEdit = p.get_node('value')
					var hints : PackedStringArray = d.hint_string.split(',')
					s.value = 0
					tb.text = '%.2f' % 0
					if hints.size() > 1:
						s.min_value = hints[0].to_float()
						s.max_value = hints[1].to_float()
						if hints.size() > 2:
							s.step = hints[2].to_float()
					s.value_changed.connect(  Callable(_effect_float_slider_changed).bind(d.name,p) )
					tb.text_submitted.connect(   Callable(_effect_float_value_changed).bind(d.name, p) )
					%effectParms.add_child(p)
		%uniforms.visible = false
		canvas.material = m
	#if currentFrame:
		#currentFrame.visible = false
		#currentFrame = null
	#if index > 0:
		#currentFrame = frames.get_child(index - 1)
		#currentFrame.visible = true
		#
		#%frameColor.color = currentFrame.modulate
		#
		#if currentFrame.has_meta('range'):
			#var limit : Vector2 = currentFrame.get_meta('range')
			#%frameSlider.min_value = limit.x
			#%frameSlider.max_value = limit.y
			#
		#var mat = currentFrame.material 
		#if mat is ShaderMaterial:
			#mat.set_shader_parameter('rect_size',canvas.size)
			#%frameSlider.value = mat.get_shader_parameter('threshold')
	#match index:
		#0:
			#pass
		#1:
			#pass
			
	pass # Replace with function body.


func _on_seamless_mode_toggled(toggled_on: bool) -> void:
	_brush_warp(toggled_on)
	seamlessMode = toggled_on
	pass # Replace with function body.


func _on_save_dialog_canceled() -> void:
	#print('cancled')
	cancled = true
	pass # Replace with function body.


func _on_background_resized() -> void:
	_center_view()
	pass # Replace with function body.


func _adjust_height(width_value: String) -> void:
	if %keepRatio.button_pressed:
		var ratio :float =  image.get_height() as float / image.get_width()
		var newHeight = width_value.to_int() * ratio
		%height.text = str(roundi(newHeight))
	pass # Replace with function body.


func _adjust_width(height_value: String) -> void:
	if %keepRatio.button_pressed:
		var ratio = image.get_width() as float / image.get_height()
		var newWidth = height_value.to_int() * ratio
		%width.text = str(roundi(newWidth))
	pass # Replace with function body.


func _on_tex_filter_option_item_selected(index: int) -> void:
	match index:
		0:
			%SubViewportContainer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			%viewport.canvas_item_default_texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			%paintViewPort.canvas_item_default_texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		1:
			%SubViewportContainer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			%viewport.canvas_item_default_texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			%paintViewPort.canvas_item_default_texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pass # Replace with function body.


func _on_grid_toggle_toggled(toggled_on: bool) -> void:
	var m = %SubViewportContainer.material
	if m is ShaderMaterial:
		m.set_shader_parameter('grid',toggled_on)
		m.set_shader_parameter('gridSize',Vector2(image.get_size()))
	pass # Replace with function body.


func _on_brush_types_item_selected(index: int) -> void:
	brushSlot = index
	var brushTexture : Texture2D = %brushTypes.get_item_icon(index)
	line.width = brush.size.y
	brush.texture = brushTexture
	for c in brush.get_children():
		if c is TextureRect:
			c.texture = brush.texture
			
	line.visible = false
	continuousBrush = true
	match brushSlot:
		0:
			line.visible = true
			continuousBrush = false
			line.end_cap_mode =Line2D.LINE_CAP_ROUND
			line.begin_cap_mode =Line2D.LINE_CAP_ROUND
		1:
			line.visible = true
			continuousBrush = false
			line.end_cap_mode =Line2D.LINE_CAP_BOX
			line.begin_cap_mode =Line2D.LINE_CAP_BOX
			
	_update_neighbor_brushes()
	
	pass # Replace with function body.


func _on_rand_rot_text_submitted(new_text: String) -> void:
	randomBrushRotation = new_text.to_float()
	pass # Replace with function body.


func _on_rand_size_text_submitted(new_text: String) -> void:
	randBrushSize = new_text.to_float()
	pass # Replace with function body.


func _on_rand_pos_text_changed(new_text: String) -> void:
	randBrushPos = new_text.to_float()
	pass # Replace with function body.


func _on_use_rand_col_toggled(toggled_on: bool) -> void:
	useRandBrushCol = toggled_on
	pass # Replace with function body.


func _on_rand_color_from_color_changed(color: Color) -> void:
	randColFrom = color
	pass # Replace with function body.


func _on_rand_color_to_color_changed(color: Color) -> void:
	randColTo = color # Replace with function body.
