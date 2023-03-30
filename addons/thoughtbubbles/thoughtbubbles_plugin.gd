@tool
extends EditorPlugin

var plugin 

func _enter_tree():
	plugin = preload("res://addons/thoughtbubbles/Button.gd").new()
	add_inspector_plugin(plugin)
	#print(EditorInterface.get_editor_interface().get_selection())


func _exit_tree():
	remove_inspector_plugin(plugin)
