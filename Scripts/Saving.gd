extends Spatial

var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"

var bubble_node
var bubble_interface_node 
var parent_space_node 
var parent_bubble_node


func _enter_tree():
	bubble_node = get_parent()
	bubble_interface_node = get_parent().get_parent()
	parent_space_node = get_parent().get_parent().get_parent()
	parent_bubble_node = get_parent().get_parent().get_parent().get_parent()
	
	#Check if bubble is in a "Space" and not under the top "Scene" node
	if (parent_space_node.get_name() != get_viewport().get_child(0).get_name()):
		#Connect to signals in parent Space
		parent_space_node.connect("save_thoughts" , self, "save_thought")
	
func save_thought(timestamp):
	save_name(timestamp)
	save_position(timestamp)
	save_basis(timestamp)
	save_links(timestamp)
	save_color(timestamp)
	
	#Collect all meta properties
	#execute external python script and pass it the node name and each property

func save_name(timestamp):
	# Name
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Thought|", "|Text|", bubble_interface_node.get_name()], false)

func save_position(timestamp):
	# Position
	save_bubble_property("Transform", "Position", "x", timestamp, str(bubble_interface_node.transform.origin.x))
	save_bubble_property("Transform", "Position", "y", timestamp, str(bubble_interface_node.transform.origin.y))
	save_bubble_property("Transform", "Position", "z", timestamp, str(bubble_interface_node.transform.origin.z))

func save_basis(timestamp):
		# Basis
	save_bubble_property("Transform", "Basis", "xx", timestamp, str(bubble_interface_node.transform.basis.x.x))
	save_bubble_property("Transform", "Basis", "xy", timestamp, str(bubble_interface_node.transform.basis.x.y))
	save_bubble_property("Transform", "Basis", "xz", timestamp, str(bubble_interface_node.transform.basis.x.z))
	
	save_bubble_property("Transform", "Basis", "yx", timestamp, str(bubble_interface_node.transform.basis.y.x))
	save_bubble_property("Transform", "Basis", "yy", timestamp, str(bubble_interface_node.transform.basis.y.y))
	save_bubble_property("Transform", "Basis", "yz", timestamp, str(bubble_interface_node.transform.basis.y.z))
	
	save_bubble_property("Transform", "Basis", "zx", timestamp, str(bubble_interface_node.transform.basis.z.x))
	save_bubble_property("Transform", "Basis", "zy", timestamp, str(bubble_interface_node.transform.basis.z.y))
	save_bubble_property("Transform", "Basis", "zz", timestamp, str(bubble_interface_node.transform.basis.z.z))

func save_color(timestamp):
	# Color
	save_bubble_property("Material", "Color", "r", timestamp, str(bubble_node.bubble_color.r))
	save_bubble_property("Material", "Color", "g", timestamp, str(bubble_node.bubble_color.g))
	save_bubble_property("Material", "Color", "b", timestamp, str(bubble_node.bubble_color.b))
	save_bubble_property("Material", "Color", "a", timestamp, str(bubble_node.bubble_color.a))

func save_bubble_property(field, property, element, timestamp, value):
	if (bubble_node.get_node("Loading").get_latest_bubble_property_value(property, element) != value && value != ""):
		var save_array = ["|Godot|", "|Bubble|", parent_bubble_node.get_name() , bubble_interface_node.get_name(), "|" + field + "|", "|" + property + "|", "|" + element + "|", timestamp, value]
		#print(lookup_array)
		OS.execute(godot_to_nodes_path, save_array, false)

func save_links(timestamp):
	for link in bubble_node.child_thoughts:
		print(bubble_interface_node.get_name() + " saving... " + link)
		OS.execute(godot_to_nodes_path, [ "|Godot|", parent_bubble_node.get_name(), bubble_interface_node.get_name(),  "|Link|", timestamp, str(link).replace("../", "")], false)
