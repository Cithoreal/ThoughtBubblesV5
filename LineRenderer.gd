tool
extends Node

var m = SpatialMaterial.new()

var path = []
var show_path = true

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	set_process_input(true)
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color.red
	path.append(Vector3(-1,0,0)) 
	path.append(Vector3(0,1,0))
	draw_path(path)

func draw_path(path_array):
	var im = get_node("Draw")
	im.set_material_override(m)
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(path_array[0])
	im.add_vertex(path_array[path_array.size() - 1])
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path:
		im.add_vertex(x)
	im.end()
