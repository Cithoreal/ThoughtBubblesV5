tool
extends ImmediateGeometry

var m = SpatialMaterial.new()

var show_path = true
export var this_bubble : NodePath
export var linked_bubble : NodePath
var path = []
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	set_process_input(true)
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color.blue


func _process(_delta):
	path.clear()
	path.append(get_node(this_bubble).transform.origin) 
	path.append(get_node(linked_bubble).transform.origin)
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
