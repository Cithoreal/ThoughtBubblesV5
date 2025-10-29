@tool
extends Node3D

func set_thought(thought_string):
	get_child(0).text = thought_string
