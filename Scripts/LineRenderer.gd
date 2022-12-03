tool
extends ImmediateGeometry

var mat = SpatialMaterial.new()

var show_path = true
var bubble1 : Spatial
var bubble2 : Spatial
export var link1 : String
export var link2 : String
export var link_color : Color
var path = []
# Called when the node enters the scene tree for the first time.
	
func _enter_tree():
	if (link1 != "" && get_parent().get_parent().get_child(2).find_node(link1)):
		bubble1 = get_parent().get_parent().get_child(2).get_node(link1)
	else:
		bubble1 = get_parent().get_parent().get_parent()
	if (link2 != ""):
		bubble2 = get_parent().get_parent().get_child(2).get_node(link2)
		initialize()
	
func initialize():
	if (bubble2 != null):
		link_color = bubble2.bubble_color
		set_process_input(true)
		mat.flags_unshaded = true
		mat.flags_use_point_size = true
		mat.albedo_color = link_color
		mat.albedo_color = bubble2.bubble_color
		link1 = str(bubble1.get_name())
		link2 = str(bubble2.get_name())

func _process(_delta):
	if bubble1 == null or bubble2 == null:
		return
	path.clear()
	path.append(bubble1.global_transform.origin) 
	path.append(bubble2.global_transform.origin)
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
