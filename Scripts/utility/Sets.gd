@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func IntersectArrays(array1: Array, array2: Array) -> Array:
	var result: Array = []
	for item in array1:
		if item in array2:
			result.append(item)
	return result
