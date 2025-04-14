# addons/image_editor/plugin.gd
@tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = preload("res://addons/image_editor/dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	add_tool_menu_item("Image Editor", _show_dock)

func _exit_tree():
	remove_control_from_docks(dock)
	remove_tool_menu_item("Image Editor")

func _show_dock():
	dock.visible = true
