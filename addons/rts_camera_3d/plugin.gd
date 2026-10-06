@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"RTSCamera", "Camera3D",
		load("res://addons/rts_camera_3d/rts_camera.gd"),
		load("res://addons/rts_camera_3d/icon_rts_camera.png")
	)


func _exit_tree():
	remove_custom_type("RTSCamera")

