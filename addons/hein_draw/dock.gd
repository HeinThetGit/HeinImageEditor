# addons/image_editor/dock.gd
@tool
class_name dock
extends Control

@onready var file_dialog = $FileDialog
var cancled : bool
#@onready var load_button = $VBoxContainer/LoadButton
@onready var slider : Slider = %brightnessSlider
@onready var save_button = %SaveButton
@onready var view : TextureRect = %view
@onready var noti : Label = %noti
@onready var background : Control = %background
@onready var imageView : SubViewportContainer = %SubViewportContainer
@onready var canvas : TextureRect = %canvas
@onready var paintRender : SubViewport = %paintViewPort
@onready var brush : TextureRect = %brush
@onready var nb : Line2D = %north
@onready var sb : Line2D = %south
@onready var eb : Line2D = %east
@onready var wb : Line2D = %west
@onready var line : Line2D = %Line2D

var canvasMaterial : ShaderMaterial
var brushMaterial : CanvasItemMaterial
var lineMaterial : CanvasItemMaterial
var paintLayerMaterial : CanvasItemMaterial
var lastStroke : Vector2
var drawing : bool
var seamlessMode : bool

var path : String
var image: Image
var zoom : float = 1
var originalImage: Image

var currentTab : int
var cropStart : Vector2
var cropEnd : Vector2

@onready var frames : Control = %frames
@onready var frameOptions : OptionButton = %frameOptions
var currentFrame : Control

func _ready():
	#file_dialog.connect("confirmed",Callable(save) )
	#file_dialog.set_meta('created_by',self)
	
	brush.visible = false
	brushMaterial = %brush.material
	lineMaterial = line.material
	paintLayerMaterial = %paintLayer.material
	canvasMaterial = %canvas.material
	var t : Texture2D = %canvas.texture
	originalImage = t.get_image()
	image =  originalImage.duplicate()
	
	update()
	reset_parm()
	fit()
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
	%zoomSlider.value = minimunFit
	
	_center_view()
	
	_update_rect_size_on_shader(imageView, Vector2(image.get_size())*zoom)
	#imageView.position = background.size / 2
	#imageView.position -= (Vector2(image.get_size() ) / 2) * imageView.scale

func _center_view():
	if !background:
		return
	imageView.position = background.size / 2
	imageView.position -= (Vector2(image.get_size() ) / 2) * imageView.scale

	
func reset_parm():
	#canvasMaterial.set_shader_parameter("brightness",0)
	%brightnessSlider.value = 0
	_on_brightness_slider_changed(0)
	#canvasMaterial.set_shader_parameter("contrast",0)
	%contrastValue.value = 0
	_on_contrast_value_drag_ended(0)
	
	%saturationValue.value = 1
	_set_shader_float(1,'saturation')
	#canvasMaterial.set_shader_parameter("tint_color",Color.WHITE)
	%tintColor.color = Color.WHITE
	_on_tint_color_color_changed(Color.WHITE)
	%brushSizeValue.value = 10
	brush.modulate = Color.RED
	%brushColor.color = Color.RED
	%brushBlend.selected = 0
	_on_brush_blend_tab_changed(0)
	
	%frameSlider.value = 0
	%frameColor.color = Color.WHITE
	_frame_color_changed(Color.WHITE)
	%frameOptions.select(0)
	
	pass
func _on_file_selected():
	toast(file_dialog.current_path)
	path = file_dialog.current_path
	originalImage = Image.load_from_file(path)
	image = originalImage.duplicate()
	update()
	fit()
	reset_parm()
	#var s = %background.size.x / image.get_size().y
	#%SubViewportContainer.scale = Vector2.ONE * s
	#%zoomSlider.value = s
	update()
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
	_set_neighbor_brush_dist()
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
		print("saved as jpg")
		#%viewport.
	if e == "png" :
		
		captured.save_png(savePath)
		print("file saved!")
		print(savePath)
	toast(e +" Saved! "+ savePath)
	path = savePath
	EditorInterface.get_resource_filesystem().scan_sources()

func _on_brightness_slider_changed(value_changed: float) -> void:
	canvasMaterial.set_shader_parameter('brightness',value_changed)


func _on_revert_button_up() -> void:
	image = originalImage.duplicate()
	reset_parm()
	_clear_paint()
	update()
	fit()
	pass # Replace with function body.

		
func _on_zoom_value_changed(value: float) -> void:
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
	%brush.visible = false
	#%viewport.render_target_clear_mode = 1
	match tab:
		3:
			%cropRect.visible = true
		4:
			%viewport.render_target_clear_mode = 0
	pass # Replace with function body.


func _on_crop_right_value_changed(value: float) -> void:
	cropEnd.x = value * image.get_width()
	_update_crop_region()
	pass # Replace with function body.


func _on_crop_buttom_value_changed(value: float) -> void:
	cropEnd.y = value * image.get_size().y
	_update_crop_region()
	
	pass # Replace with function body.

func _update_crop_region():
	%cropRect.visible = true
	%cropRect.position = cropStart
	%cropRect.size =  cropEnd - cropStart
	pass
func _on_crop_top_value_changed(value: float) -> void:
	cropStart.y = value * image.get_height()
	_update_crop_region()
	#var e = %cropRect.get_end()
	#e.y
	#%cropRect.set_end(e)
	pass # Replace with function body.


func _on_crop_left_value_changed(value: float) -> void:
	cropStart.x = value * image.get_width()
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


func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			#line.reparent(%paintLayer)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				%zoomSlider.value += 0.1
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				%zoomSlider.value -= 0.1
			
		if event.button_index == 1:
			#brush.visible = !event.is_released() && currentTab == 4
			drawing = !event.is_released() && currentTab == 4
		
		if event.is_released():
			#drawing = false
			#line.reparent(%paintViewPort)
			#await get_tree().process_frame
			
			line.visible = false
			line.clear_points()
			nb.clear_points()
			sb.clear_points()
			eb.clear_points()
			wb.clear_points()
			
	
		#print(event.button_index)
	if event is InputEventMouse:
		var pointerPos = event.position * (1/zoom) - (imageView.position * (1/zoom) )
		var pos = pointerPos - brush.size / 2
		brush.position = pos
		if drawing:
			#Obviously, line render wont display a line if the two point are identical
			#But we need to display a dot at mouse position if the pointer doesnt move
			# thus adding an offset to the second point
			line.visible = true
			if line.get_point_count() == 0:
				var offset = pointerPos + Vector2(0.001,0)
				line.add_point(pointerPos)
				line.add_point(offset)
				
				if seamlessMode:
					_add_neighor_brush_point(offset)
					_add_neighor_brush_point(pointerPos)
			else:
				line.add_point(pointerPos)
				if seamlessMode:
					_add_neighor_brush_point(pointerPos)
	#print("evenr")
	pass # Replace with function body.

func _add_neighor_brush_point(pos : Vector2):
	nb.add_point(pos)
	sb.add_point(pos)
	eb.add_point(pos)
	wb.add_point(pos)

func _set_neighbor_brush_dist():
	nb.position.y = -%canvas.size.y
	sb.position.y = %canvas.size.y
	eb.position.x = %canvas.size.x
	wb.position.x = -%canvas.size.x
	
func _on_brush_color_color_changed(color: Color) -> void:
	brush.modulate = color
	line.default_color = color
	sb.default_color = color
	nb.default_color = color
	eb.default_color = color
	wb.default_color = color
	pass # Replace with function body.


func _create_new_image(width : int, height : int, color : Color) -> void:
	#_on_revert_button_up()
	path = ""
	%paintViewPort.render_target_clear_mode = 2
	originalImage = Image.create(width, height, false, Image.FORMAT_RGBA8)
	originalImage.fill(color)
	image = originalImage.duplicate()
	update()
	fit()
	pass # Replace with function body.


func _on_brush_blend_tab_changed(tab: int) -> void:
	#brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	#paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	match tab:
		0:
			paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			
		1:
			paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
			lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
		2:
			paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		3:
			paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			lineMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		
	pass # Replace with function b
	

func _on_brush_size_value_value_changed(value: float) -> void:
	brush.scale = Vector2.ONE * value
	line.width = value
	%brushSizeText.text = str(value)
	nb.width = value
	sb.width = value
	eb.width = value
	wb.width = value
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

func apply_effect():
	image = %viewport.get_texture().get_image()
	_clear_paint()
	reset_parm()
	
func _clear_paint():
	paintRender.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	#paintRender.render_target_update_mode = SubViewport.UPDATE_ONCE
	pass


func _on_create_dialog_confirmed() -> void:
	_create_new_image(%initWidth.text.to_int(), %initHeight.text.to_int(), %initColor.color)
	pass # Replace with function body.


func _on_brush_size_text_text_submitted(new_text: String) -> void:
	#_on_brush_size_value_value_changed(new_text.to_int())
	%brushSizeValue.value = new_text.to_int()
	pass # Replace with function body.


func _on_frame_option_item_selected(index: int) -> void:
	
	
	if currentFrame:
		currentFrame.visible = false
		currentFrame = null
	if index > 0:
		currentFrame = frames.get_child(index - 1)
		currentFrame.visible = true
		
		%frameColor.color = currentFrame.modulate
		
		if currentFrame.has_meta('range'):
			var limit : Vector2 = currentFrame.get_meta('range')
			%frameSlider.min_value = limit.x
			%frameSlider.max_value = limit.y
			
		var mat = currentFrame.material 
		if mat is ShaderMaterial:
			mat.set_shader_parameter('rect_size',canvas.size)
			%frameSlider.value = mat.get_shader_parameter('threshold')
	match index:
		0:
			pass
		1:
			pass
			
	pass # Replace with function body.


func _on_seamless_mode_toggled(toggled_on: bool) -> void:
	_set_neighbor_brush_dist()
	print(nb.position)
	seamlessMode = toggled_on
	pass # Replace with function body.


func _on_save_dialog_canceled() -> void:
	print('cancled')
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
