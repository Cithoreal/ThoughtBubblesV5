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
		print("test")
		#Connect to signals in parent Space
		parent_space_node.connect("load_parents", self, "load_parents")
		parent_space_node.connect("load_thought_properties", self, "load_thought_properties")
	
func load_thought_properties(timestamp, focused):
	print(str(Time.get_time_string_from_system()) + ": Loading " + bubble_interface_node.get_name())
	load_position(timestamp, focused)
	print(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Position")
	load_color(timestamp, focused)
	print(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Color")
	load_links(timestamp)
	print(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Links")



func load_position(timestamp, focused):
	var x = ""
	var y = ""
	var z = ""
	print(bubble_interface_node.get_name() + " loading position")
	x = get_bubble_property("Position" ,"x", timestamp, focused)
	y = get_bubble_property("Position", "y", timestamp, focused)
	z = get_bubble_property("Position", "z", timestamp, focused)
	#print(bubble_interface_node.get_name() + ": " + str(Vector3(float(x),float(y),float(z))))
	if (x == null):
		x = 0
	if (y == null):
		y = 0
	if (z == null):
		z = 0
	if (x == null || y == null || z == null):
		pass
		# Set to cursor position
	else:
		bubble_interface_node.transform.origin = Vector3(float(x),float(y),float(z))
	
func load_color(timestamp, focused):
	var r = ""
	var g = ""
	var b = ""
	var a = ""
	
	r = get_bubble_property("Color", "r", timestamp, focused)
	g = get_bubble_property("Color", "g", timestamp, focused)
	b = get_bubble_property("Color", "b", timestamp, focused)
	a = get_bubble_property("Color", "a", timestamp, focused)
	
	if (r == null || g == null || b == null || a == null):
		get_parent().bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)
	else:
		get_parent().bubble_color = Color(r,g,b,a)
	get_parent().get_child(0).material_override.albedo_color = get_parent().bubble_color

func load_links(timestamp):
	var output = []
	OS.execute(MB_to_godot_path, [parent_bubble_node.get_name(), bubble_interface_node.get_name(), "|Link|", timestamp], true, output)
	for element in bubble_node.process_mb_output(output):
		bubble_node.child_thoughts.append(element)

func load_parents():
	for link in bubble_node.child_thoughts:
		load_parent_links(link)

func load_parent_links(link_to):
	if (parent_space_node.get_node(link_to).get_child(1).parent_thoughts.find(bubble_interface_node.get_name()) == -1):
		parent_space_node.get_node(link_to).get_child(1).parent_thoughts.append(bubble_interface_node.get_name())

func get_latest_bubble_property_value(property, element):
	var output = []
	var timestamp = ""
	#Add further thought context ability to this property value command
	#print(bubble_interface_node.get_name())
	OS.execute(MB_to_godot_path, [parent_bubble_node.get_name(), bubble_interface_node.get_name(), "|" + property + "|", "|" + element + "|", "|Timestamp|"], true, output)
	output = bubble_node.process_mb_output(output)
	if (str(output) != "[]"):
		timestamp = output[len(output)-1]
		OS.execute(MB_to_godot_path, [parent_bubble_node.get_name(), bubble_interface_node.get_name(), "|" + property + "|", "|" + element + "|", timestamp], true, output)
		if (len(bubble_node.process_mb_output(output)) > 0):
			return bubble_node.process_mb_output(output)[len(bubble_node.process_mb_output(output))-1]
		else:
			return null
	else:
		return null

func get_bubble_property(property,element,timestamp, focused):
	var output = []
	if (focused):
		OS.execute(MB_to_godot_path, [parent_bubble_node.get_name(), bubble_interface_node.get_name(), "|" + property + "|", "|" + element + "|", "|Focused|", "|True|" ,"|Timestamp|"], true, output)
	else:
		OS.execute(MB_to_godot_path, [parent_bubble_node.get_name(), bubble_interface_node.get_name(), "|" + property + "|", "|" + element + "|", "|Timestamp|"], true, output)
	output = bubble_node.process_mb_output(output)
	for time in output:
			if (time < timestamp):
				timestamp = time
				
	if (output.find(timestamp) > -1):
		OS.execute(MB_to_godot_path, [parent_bubble_node.get_name(), bubble_interface_node.get_name(), "|" + property + "|", "|" + element + "|", timestamp], true, output)
		if (len(bubble_node.process_mb_output(output)) > 0):
			return bubble_node.process_mb_output(output)[len(bubble_node.process_mb_output(output))-1]
		else:
			return null
	else:
		get_parent().visible = false
