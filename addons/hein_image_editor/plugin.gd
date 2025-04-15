@tool
extends EditorPlugin

var editor
func _enter_tree():
	editor = preload("res://addons/hein_image_editor/dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, editor)
	#add_tool_menu_item("HeinImageEdit", _show)
	
	# add editor to main viewport
	#get_editor_interface().get_editor_main_screen().add_child(editor)
	_make_visible(false)

func _exit_tree():
	# Remove from main viewpor
	if editor:
		remove_control_from_docks(editor)
		editor.queue_free()


func _has_main_screen():
	return true


func _show():
	editor.visible = true
	
func _make_visible(visible):
	if editor:
		editor.visible = visible

func _get_plugin_name():
	return "HeinEdit"
