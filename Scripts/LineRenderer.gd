@tool
extends MeshInstance3D

var mat = ORMMaterial3D.new()

var show_path = true
var bubble1 : Node3D
var bubble2 : Node3D
@export var link1 : String
@export var link2 : String
@export var link_color : Color

# Called when the node enters the scene tree for the first time.
	
#func _enter_tree():
#	if (link1 != "" && get_parent().get_parent().get_child(2).find_child(link1)):
#		bubble1 = get_parent().get_parent().get_child(2).get_node(link1)
#	else:
#		bubble1 = get_parent().get_parent().get_parent()
#	if (link2 != ""):
#		bubble2 = get_parent().get_parent().get_parent().get_node(link2)
#		initialize()
	
func initialize():
	if (bubble2 != null):
		mesh = ImmediateMesh.new()
		set_process_input(true)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = bubble2.bubble_color
		link1 = str(bubble1.get_name())
		link2 = str(bubble2.get_name())
		

func _process(_delta):
	link_color = bubble2.bubble_color
	var path = []
	if bubble1 == null or bubble2 == null:
		return
	path.clear()
	path.append(bubble1.global_transform.origin) 
	path.append(bubble2.global_transform.origin)

	

	draw_path(path)
	#print("link bubble: " + bubble2.get_name())


func draw_path(path):
	set_material_override(mat)
	#var line = ImmediateMesh.new()
	
	mesh.clear_surfaces()

	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	mesh.surface_set_color(link_color)
	#print(mesh)
	for x in path:
		mesh.surface_add_vertex(x)
	
	mesh.surface_end()
	material_override.albedo_color = link_color
