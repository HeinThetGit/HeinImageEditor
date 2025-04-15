# addons/image_editor/dock.gd
@tool
class_name dock
extends Control

@onready var file_dialog = $FileDialog
#@onready var load_button = $VBoxContainer/LoadButton
@onready var slider : Slider = %brightnessSlider
@onready var save_button = %SaveButton
@onready var view : TextureRect = %view
@onready var noti : Label = %noti
@onready var canvas : TextureRect = %canvas
@onready var brush : TextureRect = %brush
@onready var line : Line2D = %Line2D

var canvasMaterial : ShaderMaterial
var brushMaterial : CanvasItemMaterial
var paintLayerMaterial : CanvasItemMaterial
var lastStroke : Vector2
var drawing : bool

var path : String
var image: Image
var zoom : float = 1
var originalImage: Image

var currentTab : int
var cropStart : Vector2
var cropEnd : Vector2

func _ready():
	#file_dialog.connect("confirmed",Callable(save) )
	#file_dialog.set_meta('created_by',self)
	
	brush.visible = false
	brushMaterial = %brush.material
	paintLayerMaterial = %paintLayer.material
	canvasMaterial = %canvas.material
	var t : Texture2D = %canvas.texture
	originalImage = t.get_image()
	image =  originalImage.duplicate()
	
	update()
	fit()
	reset_parm()
	pass

func fit():
	#%SubViewportContainer.position = center
	
	#var newSize = min(image.get_width() / %background.size.x, image.get_height() / %background.size.y)
	#print(image.get_size())
	#print(%background.size)
	var ns = %background.size.x / image.get_width()
	#print(ns)
	%SubViewportContainer.scale = Vector2.ONE * ns
	#%SubViewportContainer.position = %canvas.size * ns / 2
	#%SubViewportContainer.pivot_offset = %canvas.size * ns / 2
	
	#%SubViewportContainer.scale = newSize
	#%SubViewportContainer.size *= newSize
	#%SubViewportContainer.scale = Vector2.ONE * s
	%zoomSlider.value = ns
	#%SubViewportContainer.positioK-= %SubViewportContainer.size * ns / 2
	#%SubViewportContainer.pivot_offset = %SubViewportContainer.size * ns / 2
	
	pass

func reset_parm():
	#canvasMaterial.set_shader_parameter("brightness",0)
	%brightnessSlider.value = 0
	%brightnessSlider.emit_signal("value_changed")
	#canvasMaterial.set_shader_parameter("contrast",0)
	%contrastValue.value = 0
	%contrastValue.emit_signal("value_changed")
	
	%saturationValue.value = 1
	#canvasMaterial.set_shader_parameter("tint_color",Color.WHITE)
	%tintColor.color = Color.WHITE
	_on_tint_color_color_changed(Color.WHITE)
	%brushSizeValue.value = 0.5
	%brushHardnessValue.value = 1
	brush.modulate = Color.RED
	%brushColor.color = Color.RED
	%alphaMask.button_pressed = false
	%alphaMask.emit_signal("toggled")
	%brushBlend.current_tab = 0
	%vignette.visible = false
	
	pass
func _on_file_selected():
	print("ss")
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
	%paintViewPort.size = image.get_size()
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
	await get_tree().create_timer(1.5).timeout
	%noti.text = ""
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
		print("saved as png")
	toast("Saved!")
	if savePath != path:
		#ResourceLoader.load(savePath, "", ResourceLoader.CACHE_MODE_REPLACE)
		#EditorResourcePreview.queue_edited_resource_reload("res://my_folder/my_image.jpg")
		EditorInterface.get_resource_filesystem().scan()
	
	#EditorInterface.inspect_object(ResourceLoader.load(path))
	#EditorInterface.get_singleton().inspect_object(ResourceLoader.load(sa

func _on_brightness_slider_changed(value_changed: float) -> void:
	#print("mmmm")
	canvasMaterial.set_shader_parameter('brightness',value_changed)
	#noti.text = "updating..."
	#await get_tree().create_timer(0.05).timeout
	#if image:
		#_apply_brightness(slider.value)
		#update()
	pass # Replace with function body.
	#noti.text = ""


func _on_revert_button_up() -> void:
	image = originalImage.duplicate()
	reset_parm()
	%paintViewPort.render_target_clear_mode = 2
	update()
	fit()
	pass # Replace with function body.


func _on_zoom_value_changed(value: float) -> void:
	zoom = value
	%SubViewportContainer.scale = Vector2.ONE * value
	#view.custom_minimum_size = Vector2.ONE * scale*100
	#view.scale = Vector2.ONE * zoom
	pass # Replace with function body.

func _openLoad():
	file_dialog.popup_centered_ratio(1)
	file_dialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
	
func _openSaveAs():
	file_dialog.popup_centered_ratio(1)
	file_dialog.FileMode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
func _on_contrast_value_drag_ended(value_changed: float) -> void:
	
	canvasMaterial.set_shader_parameter("contrast",value_changed)
	pass # Replace with function body.




func _on_save_dialog_confirmed() -> void:
	save(%saveDialog.current_path)
	pass # Replace with function body.


func _on_save_button_button_up() -> void:
	save(path)
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


func _on_h_slider_value_changed(value: float) -> void:
	var on :bool = value > 0.01
	%vignette.visible = on
		
	var mt = %vignette.material
	if mt is ShaderMaterial:
		mt.set_shader_parameter("softness_y",value)
		var ratio = canvas.size.y / canvas.size.x
		mt.set_shader_parameter("softness_x",value * ratio)
		
		
	pass # Replace with function body.


func _on_color_picker_button_color_changed(color: Color) -> void:
	%vignette.color = color
	pass # Replace with function body.




func _set_shader_float(value: float, extra_arg_0: String) -> void:
	canvasMaterial.set_shader_parameter(extra_arg_0, value)
	pass # Replace with function body.


func _on_tab_container_tab_changed(tab: int) -> void:
	currentTab = tab
	%cropRect.visible = false
	match tab:
		3:
			%cropRect.visible = true
			pass
		4:
			pass
			%viewport.render_target_clear_mode = 1
			#print("cl")
		_:
			pass
			%cropRect.visible = false
			%brush.visible = false
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
	image.rotate_90(dir)
	update()
	fit()
	pass
func _on_apply_crop_button_up() -> void:
	%cropRect.visible = false
	var cp = %cropRect.position
	var cs = %cropRect.size
	var croppedImage : Image = Image.create(cs.x, cs.y, false, image.get_format() )
	croppedImage.blit_rect(image, Rect2(cp.x, cp.y, cs.x, cs.y), Vector2(0,0) )
	
	image = croppedImage
	update()
	fit()
	
	pass # Replace with function body.


func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			#brush.visible = !event.is_released() && currentTab == 4
			drawing = !event.is_released() && currentTab == 4
		
		if event.is_released():
			#drawing = false
			%Line2D.visible = false
			%Line2D.clear_points()
			pass
		#print(event.button_index)
	if event is InputEventMouse:
		
		#if event.is_released():
			#brush.visible = false
		#print("left")
		var pos = event.position - brush.size / 2
		brush.position = pos
		if drawing:
			%Line2D.visible = true
			%Line2D.add_point(event.position)
		
		pass
	#print("evenr")
	pass # Replace with function body.


func _on_brush_color_color_changed(color: Color) -> void:
	brush.modulate = color
	line.default_color = color
	pass # Replace with function body.


func _on_new_button_button_up() -> void:
	#_on_revert_button_up()
	%paintViewPort.render_target_clear_mode = 2
	var originalImage : Image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	originalImage.fill(Color.WHITE)
	image = originalImage.duplicate()
	update()
	fit()
	pass # Replace with function body.


func _on_brush_blend_tab_changed(tab: int) -> void:
	#brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	#paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	if %alphaMask.button_pressed:
		brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		return
	match tab:
		0:
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			
		1:
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
		2:
			#paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
			brushMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		
	pass # Replace with function b
	


func _on_rotate_snap_tab_clicked(tab: int) -> void:
	_rotate_image(tab)
	pass # Replace with function body.


func _on_brush_size_value_value_changed(value: float) -> void:
	brush.scale = Vector2.ONE * value
	line.width = value
	pass # Replace with function body.


func _on_flip_image_tab_clicked(tab: int) -> void:
	if tab == 0:
		image.flip_x()
	else:
		image.flip_y()
	
	update()
	fit()
	pass # Replace with function body.


func _on_alpha_mask_toggled(toggled_on: bool) -> void:
	if toggled_on:
		paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
	else:
		paintLayerMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	pass # Replace with function body.
