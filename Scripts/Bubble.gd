tool
extends Spatial

export(Array, String) var parent_thoughts
export(Array, String) var child_thoughts  
export var bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)

var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
var mat = SpatialMaterial.new()

var bubble_interface_node 
var parent_space_node 
var thought_space_node 

# ----------------------- INITILIZATION ----------------------- #
func _enter_tree():
	
	bubble_interface_node = get_parent()
	parent_space_node = get_parent().get_parent()
	thought_space_node = get_parent().get_parent().get_parent()
	
	prepare_material()

func prepare_material():
	bubble_color = get_child(0).material.albedo_color
	mat.flags_unshaded = true
	mat.flags_use_point_size = true
	mat.flags_transparent = true
	mat.flags_use_point_size = false
	mat.albedo_color = bubble_color
	get_child(0).set_material_override(mat)

func set_color(color):
	bubble_color = color
	get_child(0).material_override.albedo_color = bubble_color

func initialize():
	bubble_interface_node.get_child(0).set_thought(bubble_interface_node.get_name())
	parent_thoughts.append(thought_space_node.get_name())
	#Lookup self in the memory base, exit if doesn't already exist
	#If it does exist, collect all properties/meta values and apply them to self

func process_mb_output(output):
	var text = output[0].replace("[(", "")
	var text_array = []
	text = text.replace(",)]", "")
	text = text.replace("\n", "")
	for i in text.split(",), ("):
		var element = i.replace("'","")
		if (element != "[]"):
			text_array.append(element)
	return text_array

