tool
extends Spatial

export(Array, String) var parent_thoughts
export(Array, String) var child_thoughts  
export var bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)
var link_node : ImmediateGeometry

var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
var link_scene = load("res://LineRenderer.tscn")
var mat = SpatialMaterial.new()

func _enter_tree():
	if (get_parent().get_parent().get_name() != get_viewport().get_child(0).get_name()):
		get_parent().get_parent().connect("save_thoughts" , self, "save_thought")
		get_parent().get_parent().connect("load_parents", self, "load_parents")
		get_parent().get_parent().connect("load_links", self, "load_link_nodes")
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
	get_parent().get_child(0).set_thought(get_parent().get_name())
	parent_thoughts.append(get_parent().get_parent().get_parent().get_name())
	load_thought_properties()
	#Lookup self in the memory base, exit if doesn't already exist
	#If it does exist, collect all properties/meta values and apply them to self

func load_thought_properties():
	print("Loading " + get_parent().get_name())
	load_position()
	load_color()
	load_links()

func load_position():
	var x = ""
	var y = ""
	var z = ""
	x = get_latest_bubble_property_value("Position" ,"x")
	y = get_latest_bubble_property_value("Position", "y")
	z = get_latest_bubble_property_value("Position", "z")
	#print(get_parent().get_name() + ": " + str(Vector3(float(x),float(y),float(z))))
	if (x == null || y == null || z == null):
		pass
		# Set to cursor position
	else:
		get_parent().transform.origin = Vector3(float(x),float(y),float(z))
	
func load_color():
	var r = ""
	var g = ""
	var b = ""
	var a = ""
	
	r = get_latest_bubble_property_value("Color", "r")
	g = get_latest_bubble_property_value("Color", "g")
	b = get_latest_bubble_property_value("Color", "b")
	a = get_latest_bubble_property_value("Color", "a")
	
	if (r == null || g == null || b == null || a == null):
		bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)
	else:
		bubble_color = Color(r,g,b,a)
	get_child(0).material_override.albedo_color = bubble_color

func load_links():
	var output = []
	OS.execute(MB_to_godot_path, [get_parent().get_name(), "|Link|"], true, output)
	for element in process_mb_output(output):
		child_thoughts.append(element)

func load_parents():
	for link in child_thoughts:
		load_parent_links(link)

#Runs on signal from thought space after all thoughts have been loaded into the scene
func load_link_nodes():
	if (len(parent_thoughts) > 0):
		var new_link_node = link_scene.instance()
		get_viewport().get_child(0).get_node("Links").add_child(new_link_node)
		#print(str(self) + " " + str(len(parent_thoughts)-1))
		if (len(parent_thoughts) == 1):
			new_link_node.bubble1 = get_parent().get_parent().get_parent()
		else: 
			new_link_node.bubble1 = get_parent().get_parent().get_node(parent_thoughts[len(parent_thoughts)-1])
		new_link_node.bubble2 = get_parent()
		new_link_node.set_owner(get_viewport().get_child(0))
		new_link_node.initialize()
		if (link_node != null):
			link_node.free()
		link_node = new_link_node

func load_parent_links(link_to):
	if (get_parent().get_parent().get_node(link_to).get_child(1).parent_thoughts.find(get_parent().get_name()) == -1):
		get_parent().get_parent().get_node(link_to).get_child(1).parent_thoughts.append(get_parent().get_name())
		

func get_latest_bubble_property_value(property, element):
	var output = []
	var timestamp = ""
	#Add further thought context ability to this property value command
	OS.execute(MB_to_godot_path, [get_parent().get_parent().get_parent().get_name(), get_parent().get_name(), "|" + property + "|", "|" + element + "|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	if (str(output) != "[]"):
		timestamp = output[len(output)-1]
		OS.execute(MB_to_godot_path, [get_parent().get_parent().get_parent().get_name(), get_parent().get_name(), "|" + property + "|", "|" + element + "|", timestamp], true, output)
		if (len(process_mb_output(output)) > 0):
			return process_mb_output(output)[0]
		else:
			return null
	else:
		return null
	

	
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
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Thought|", "|Text|", get_parent().get_name()], false)

func save_position(timestamp):
	# Position
	save_bubble_property("Transform", "Position", "x", timestamp, str(get_parent().transform.origin.x))
	save_bubble_property("Transform", "Position", "y", timestamp, str(get_parent().transform.origin.y))
	save_bubble_property("Transform", "Position", "z", timestamp, str(get_parent().transform.origin.z))

func save_basis(timestamp):
		# Basis
	save_bubble_property("Transform", "Basis", "xx", timestamp, str(get_parent().transform.basis.x.x))
	save_bubble_property("Transform", "Basis", "xy", timestamp, str(get_parent().transform.basis.x.y))
	save_bubble_property("Transform", "Basis", "xz", timestamp, str(get_parent().transform.basis.x.z))
	
	save_bubble_property("Transform", "Basis", "yx", timestamp, str(get_parent().transform.basis.y.x))
	save_bubble_property("Transform", "Basis", "yy", timestamp, str(get_parent().transform.basis.y.y))
	save_bubble_property("Transform", "Basis", "yz", timestamp, str(get_parent().transform.basis.y.z))
	
	save_bubble_property("Transform", "Basis", "zx", timestamp, str(get_parent().transform.basis.z.x))
	save_bubble_property("Transform", "Basis", "zy", timestamp, str(get_parent().transform.basis.z.y))
	save_bubble_property("Transform", "Basis", "zz", timestamp, str(get_parent().transform.basis.z.z))

func save_color(timestamp):
	# Color
	save_bubble_property("Material", "Color", "r", timestamp, str(bubble_color.r))
	save_bubble_property("Material", "Color", "g", timestamp, str(bubble_color.g))
	save_bubble_property("Material", "Color", "b", timestamp, str(bubble_color.b))
	save_bubble_property("Material", "Color", "a", timestamp, str(bubble_color.a))

func save_bubble_property(field, property, element, timestamp, value):
	if (get_latest_bubble_property_value(property, element) != value):
		var save_array = ["|Godot|", "|Bubble|", get_parent().get_parent().get_parent().get_name() , get_parent().get_name(), "|" + field + "|", "|" + property + "|", "|" + element + "|", timestamp, value]
		#print(lookup_array)
		OS.execute(godot_to_nodes_path, save_array, false)

func save_links(timestamp):
	for link in child_thoughts:
		OS.execute(godot_to_nodes_path, [ "Godot", get_parent().get_name(), "|Link|", str(link).replace("../", "")], false)

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

func create_new_thought(new_thought):
	if (child_thoughts.find(new_thought) == -1):
		if (get_parent().get_node(new_thought) == null):
			var thoughts = [get_parent().get_parent().thought_collection, get_parent().get_name()]
			print("Creating and linking " + new_thought)
			get_parent().get_parent().create_and_link_new_thought(new_thought, thoughts)
		else:
			child_thoughts.append(new_thought)
			load_parent_links(new_thought)
			get_parent().get_node(new_thought).load_link_nodes()
		print("Link to " + str(get_parent().get_node(new_thought)))

