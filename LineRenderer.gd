tool
extends ImmediateGeometry

var m = SpatialMaterial.new()

var show_path = true
export var bubble1 : NodePath
export var bubble2 : NodePath
export var link_color : Color
var path = []
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	set_process_input(true)
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = link_color


func _process(_delta):
	if bubble1 == "" or bubble2 == "":
		return
	path.clear()
	path.append(get_node(bubble1).transform.origin) 
	path.append(get_node(bubble2).transform.origin)
	draw_path(path)

func draw_path(path_array):
	set_material_override(m)
	clear()
	begin(Mesh.PRIMITIVE_POINTS, null)
	add_vertex(path_array[0])
	add_vertex(path_array[path_array.size() - 1])
	end()
	begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path:
		add_vertex(x)
	end()
