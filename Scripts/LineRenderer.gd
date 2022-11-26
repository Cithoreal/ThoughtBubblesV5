tool
extends ImmediateGeometry

var mat = SpatialMaterial.new()

var show_path = true
var bubble1 : Spatial
var bubble2 : Spatial
export var link_color : Color
var path = []
# Called when the node enters the scene tree for the first time.
	
func _enter_tree():
	mat.flags_unshaded = true
	mat.flags_use_point_size = true
	mat.albedo_color = link_color
	
func initalize():
	link_color = bubble2.bubbleColor
	set_process_input(true)
	mat.flags_unshaded = true
	mat.flags_use_point_size = true
	mat.albedo_color = link_color
	mat.albedo_color = bubble2.bubbleColor

func _process(_delta):
	if bubble1 == null or bubble2 == null:
		return
	path.clear()
	path.append(bubble1.transform.origin) 
	path.append(bubble2.transform.origin)
	draw_path(path)

func draw_path(path_array):
	set_material_override(mat)
	clear()
	begin(Mesh.PRIMITIVE_POINTS, null)
	add_vertex(path_array[0])
	add_vertex(path_array[path_array.size() - 1])
	end()
	begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path:
		add_vertex(x)
	end()
