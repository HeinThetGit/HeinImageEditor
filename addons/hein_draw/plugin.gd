@tool
extends EditorPlugin

var editor
func _enter_tree():
	editor = preload("res://addons/hein_draw/dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, editor)
	add_tool_menu_item("HeinDraw", _show)
	#get_editor_interface().get_editor_main_screen().remove_child(editor)
	
	# add editor to main viewport
	#get_editor_interface().get_editor_main_screen().add_child(editor)
	_make_visible(false)

func _exit_tree():
	# Remove from main viewpor
	if editor:
		#get_editor_interface().get_editor_main_screen().remove_child(editor)
		remove_control_from_docks(editor)
		remove_tool_menu_item("HeinDraw")
		editor.queue_free()
		


#func _has_main_screen():
	#return true


func _show():
	pass
	editor.visible = true
	
func _make_visible(visible):
	if editor:
		editor.visible = visible


func _get_plugin_name():
	return "HeinDraw"
