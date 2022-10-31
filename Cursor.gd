tool
extends Spatial

export var offset : Vector3
func _process(delta):
	
	var spatialeditor_viewport_container = find_SpatialEditorViewportContainer(get_node("/root/EditorNode"), 0)
	var viewports_3d = find_viewports_3d(spatialeditor_viewport_container)
	
	# viewports_3d[ <viewport index 0-3> ] = {
	#     "viewport_container": ViewportContainer,
	#     "viewport": Viewport,
	#     "camera": Camera,
	#     "control": Control, 
	# }
	#      Indices:
	# 1 viewport: index 0
	# 2 viewports (both ways): indices 0 and 2
	# 3 viewports: indices 0, 2 and 3
	# 4 viewports: indices 0, 1, 2, 3
	
	#print( viewports_3d[0]["camera"].fov ) # Prints 70 (if you haven't changed)
	#print( viewports_3d[0]["camera"].transform.origin)
	#print (viewports_3d[0]["camera"].transform.basis)
	#print(transform.basis)
	transform.origin = viewports_3d[0]["camera"].transform.origin + offset


#While being manipulated, cancel the follow process with the viewport
#When Manipulation ends, assign the offset to a variable and apply it to the follow process


func find_viewports_3d(spatial_editor_viewport_container) -> Array:
	var result = []
	for spatial_editor_viewport in spatial_editor_viewport_container.get_children():
		var viewport_container = spatial_editor_viewport.get_child(0)
		var control = spatial_editor_viewport.get_child(1)
		var viewport = viewport_container.get_child(0)
		var camera = viewport.get_child(0)
		result.append( {
			"viewport_container": viewport_container,
			"viewport": viewport,
			"camera": camera,
			"control": control,
		} )
	return result

func find_SpatialEditorViewportContainer(node: Node, recursive_level):
	if node.get_class() == "SpatialEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_SpatialEditorViewportContainer(child, recursive_level)
			if result != null:
				return result
